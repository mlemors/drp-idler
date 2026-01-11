import Foundation

/// Discord RPC Client - Main connection manager
@MainActor
public class DiscordRPCClient: ObservableObject {
    @Published public var isConnected = false
    @Published public var currentUser: String?
    
    private var fileHandle: FileHandle?
    private var connectionTask: Task<Void, Never>?
    private var reconnectTimer: Timer?
    private var clientId: String = ""
    private let appStartTime = Date()
    
    private let maxPipes = 10
    private let reconnectInterval: TimeInterval = 5.0
    
    public init() {}
    
    // MARK: - Public Methods
    
    /// Start the connection loop that continuously tries to connect
    public func startConnectionLoop() async {
        connectionTask = Task {
            while !Task.isCancelled {
                if !isConnected {
                    await attemptConnection()
                }
                try? await Task.sleep(nanoseconds: UInt64(reconnectInterval * 1_000_000_000))
            }
        }
    }
    
    /// Attempt to connect to Discord
    private func attemptConnection() async {
        // On macOS, Discord uses different paths
        // Try environment variable paths first
        if let xdgRuntime = ProcessInfo.processInfo.environment["XDG_RUNTIME_DIR"] {
            for pipe in 0..<maxPipes {
                let pipePath = "\(xdgRuntime)/discord-ipc-\(pipe)"
                if FileManager.default.fileExists(atPath: pipePath) {
                    if await connect(to: pipePath) {
                        return
                    }
                }
            }
        }
        
        // Try /tmp paths (Linux/some macOS setups)
        for pipe in 0..<maxPipes {
            let pipePath = "/tmp/discord-ipc-\(pipe)"
            
            if FileManager.default.fileExists(atPath: pipePath) {
                if await connect(to: pipePath) {
                    return
                }
            }
        }
        
        // Try ~/Library/Application Support/discord paths (macOS)
        let homeDir = FileManager.default.homeDirectoryForCurrentUser.path
        for pipe in 0..<maxPipes {
            let pipePath = "\(homeDir)/Library/Application Support/discord/discord-ipc-\(pipe)"
            if FileManager.default.fileExists(atPath: pipePath) {
                if await connect(to: pipePath) {
                    return
                }
            }
        }
        
        print("[RPC] No Discord IPC pipes found. Is Discord running?")
    }
    
    /// Connect to a specific pipe
    private func connect(to pipePath: String) async -> Bool {
        fileHandle = FileHandle(forUpdatingAtPath: pipePath)
        
        guard let handle = fileHandle else {
            return false
        }
        
        // Send handshake
        if await sendHandshake() {
            // Wait for ready response
            if await waitForReady() {
                isConnected = true
                return true
            }
        }
        
        handle.closeFile()
        fileHandle = nil
        return false
    }
    
    /// Send handshake message
    private func sendHandshake() async -> Bool {
        guard !clientId.isEmpty else { return false }
        
        let handshake: [String: Any] = [
            "v": 1,
            "client_id": clientId
        ]
        
        return await sendPayload(opcode: .handshake, data: handshake)
    }
    
    /// Wait for READY event from Discord
    private func waitForReady() async -> Bool {
        // In a real implementation, we'd listen for incoming data
        // For now, we assume success after handshake
        // TODO: Implement proper response reading
        try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
        return true
    }
    
    /// Send SET_ACTIVITY command
    public func setActivity(_ activity: RichPresence, activityType: ActivityType) async {
        guard isConnected else { return }
        
        var activityDict: [String: Any] = [
            "type": activityType.rawValue,
            "instance": false
        ]
        
        if let details = activity.details, !details.isEmpty {
            activityDict["details"] = details
        }
        
        if let state = activity.state, !state.isEmpty {
            activityDict["state"] = state
        }
        
        if let assets = activity.assets {
            var assetsDict: [String: String] = [:]
            if let large = assets.largeImage, !large.isEmpty {
                assetsDict["large_image"] = large
            }
            if let largeText = assets.largeText, !largeText.isEmpty {
                assetsDict["large_text"] = largeText
            }
            if let small = assets.smallImage, !small.isEmpty {
                assetsDict["small_image"] = small
            }
            if let smallText = assets.smallText, !smallText.isEmpty {
                assetsDict["small_text"] = smallText
            }
            if !assetsDict.isEmpty {
                activityDict["assets"] = assetsDict
            }
        }
        
        if let timestamps = activity.timestamps {
            var timestampsDict: [String: Int] = [:]
            if let start = timestamps.start {
                timestampsDict["start"] = start
            }
            if let end = timestamps.end {
                timestampsDict["end"] = end
            }
            if !timestampsDict.isEmpty {
                activityDict["timestamps"] = timestampsDict
            }
        }
        
        if let party = activity.party, let size = party.size, size.count == 2 {
            activityDict["party"] = [
                "id": party.id ?? "discordrpc-idler",
                "size": size
            ]
        }
        
        if let buttons = activity.buttons, !buttons.isEmpty {
            activityDict["buttons"] = buttons.map { ["label": $0.label, "url": $0.url] }
        }
        
        let args: [String: Any] = [
            "pid": ProcessInfo.processInfo.processIdentifier,
            "activity": activityDict
        ]
        
        let payload: [String: Any] = [
            "cmd": RPCCommand.setActivity.rawValue,
            "args": args,
            "nonce": UUID().uuidString
        ]
        
        _ = await sendPayload(opcode: .frame, data: payload)
    }
    
    /// Clear activity (disconnect)
    func clearActivity() async {
        let args: [String: Any] = [
            "pid": ProcessInfo.processInfo.processIdentifier
        ]
        
        let payload: [String: Any] = [
            "cmd": RPCCommand.setActivity.rawValue,
            "args": args,
            "nonce": UUID().uuidString
        ]
        
        _ = await sendPayload(opcode: .frame, data: payload)
    }
    
    /// Update client ID
    public func updateClientId(_ newClientId: String) {
        if clientId != newClientId {
            clientId = newClientId
            Task {
                await disconnect()
                await reconnect()
            }
        }
    }
    
    /// Reconnect to Discord
    public func reconnect() async {
        await disconnect()
        await attemptConnection()
    }
    
    /// Disconnect from Discord
    public func disconnect() async {
        connectionTask?.cancel()
        connectionTask = nil
        
        fileHandle?.closeFile()
        fileHandle = nil
        
        isConnected = false
        currentUser = nil
    }
    
    // MARK: - Private Helpers
    
    /// Send a payload to Discord
    private func sendPayload(opcode: RPCOpcode, data: [String: Any]) async -> Bool {
        guard let handle = fileHandle else { return false }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            
            // Discord RPC packet format:
            // [4 bytes: opcode][4 bytes: length][n bytes: json payload]
            var packet = Data()
            
            // Opcode (little endian)
            var opcodeValue = opcode.rawValue.littleEndian
            packet.append(Data(bytes: &opcodeValue, count: 4))
            
            // Length (little endian)
            var length = UInt32(jsonData.count).littleEndian
            packet.append(Data(bytes: &length, count: 4))
            
            // Payload
            packet.append(jsonData)
            
            try handle.write(contentsOf: packet)
            return true
            
        } catch {
            print("Failed to send payload: \(error)")
            return false
        }
    }
    
    /// Get timestamp for activity
    func getTimestamp(mode: TimestampMode, customTimestamp: Date?) -> RPCTimestamps? {
        switch mode {
        case .none:
            return nil
        case .sinceStart:
            return RPCTimestamps(start: Int(appStartTime.timeIntervalSince1970))
        case .custom:
            if let custom = customTimestamp {
                return RPCTimestamps(start: Int(custom.timeIntervalSince1970))
            }
            return nil
        }
    }
}
