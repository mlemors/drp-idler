import Foundation
import Darwin

/// Discord RPC Client - Main connection manager
@MainActor
public class DiscordRPCClient: ObservableObject {
    @Published public var isConnected = false
    @Published public var currentUser: String?
    @Published public var isActivityEnabled = false
    
    private var socketFd: Int32 = -1
    private var connectionTask: Task<Void, Never>?
    private var reconnectTimer: Timer?
    private var clientId: String = ""
    private let appStartTime = Date()
    
    private let maxPipes = 10
    private let reconnectInterval: TimeInterval = 5.0
    
    public init() {
        // Load saved state
        self.isActivityEnabled = SettingsManager.shared.isActivityEnabled
    }
    
    // MARK: - Activity Control
    
    /// Toggle activity on/off
    public func toggleActivity() async {
        isActivityEnabled.toggle()
        SettingsManager.shared.isActivityEnabled = isActivityEnabled
        
        print("[RPC] Activity toggled: \(isActivityEnabled ? "Enabled" : "Disabled")")
        
        if !isActivityEnabled {
            // Clear activity when disabled
            await clearActivity()
        } else {
            // Send activity when enabled
            print("[RPC] Activity enabled, sending current activity...")
            let settings = SettingsManager.shared
            
            // Build timestamps
            let startTimestamp = Int(Date().timeIntervalSince1970)
            let timestamps = RPCTimestamps(start: startTimestamp, end: nil)
            
            // Build party if set
            var party: RPCParty? = nil
            if settings.partySize > 0 && settings.partyMax > 0 {
                party = RPCParty(
                    id: "party-\(UUID().uuidString)",
                    size: [settings.partySize, settings.partyMax]
                )
            }
            
            // Build buttons if set
            var buttons: [RPCButton]? = nil
            if !settings.button1Text.isEmpty && !settings.button1URL.isEmpty {
                buttons = [RPCButton(label: settings.button1Text, url: settings.button1URL)]
            }
            
            // Create rich presence
            let richPresence = RichPresence(
                details: settings.details.isEmpty ? nil : settings.details,
                state: settings.state.isEmpty ? nil : settings.state,
                timestamps: timestamps,
                assets: nil,
                party: party,
                buttons: buttons
            )
            
            print("[RPC] Sending activity after enable: details=\(settings.details), state=\(settings.state)")
            
            // Send to Discord
            await setActivity(richPresence, activityType: settings.activityType)
        }
    }
    
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
        // Try macOS temp directory first (where Discord actually puts the socket on macOS)
        if let tempDir = ProcessInfo.processInfo.environment["TMPDIR"] {
            print("[RPC] Checking TMPDIR: \(tempDir)")
            for pipe in 0..<maxPipes {
                let pipePath = "\(tempDir)discord-ipc-\(pipe)"
                print("[RPC] Trying \(pipePath), exists: \(FileManager.default.fileExists(atPath: pipePath))")
                if FileManager.default.fileExists(atPath: pipePath) {
                    if await connect(to: pipePath) {
                        print("[RPC] Connected to Discord via \(pipePath)")
                        return
                    } else {
                        print("[RPC] Connection attempt to \(pipePath) failed")
                    }
                }
            }
        }
        
        // Try /var/folders temp directory (alternative macOS path)
        let varFoldersPaths = [
            "/var/folders/",
        ]
        
        for basePath in varFoldersPaths {
            if FileManager.default.fileExists(atPath: basePath) {
                do {
                    let contents = try FileManager.default.subpathsOfDirectory(atPath: basePath)
                    for subpath in contents {
                        if subpath.contains("discord-ipc-") {
                            let fullPath = basePath + subpath
                            if await connect(to: fullPath) {
                                print("[RPC] Connected to Discord via \(fullPath)")
                                return
                            }
                        }
                    }
                } catch {
                    // Ignore permission errors
                }
            }
        }
        
        // Try environment variable paths
        if let xdgRuntime = ProcessInfo.processInfo.environment["XDG_RUNTIME_DIR"] {
            for pipe in 0..<maxPipes {
                let pipePath = "\(xdgRuntime)/discord-ipc-\(pipe)"
                if FileManager.default.fileExists(atPath: pipePath) {
                    if await connect(to: pipePath) {
                        print("[RPC] Connected to Discord via \(pipePath)")
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
                    print("[RPC] Connected to Discord via \(pipePath)")
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
                    print("[RPC] Connected to Discord via \(pipePath)")
                    return
                }
            }
        }
        
        print("[RPC] No Discord IPC pipes found. Is Discord running?")
    }
    
    /// Connect to a specific pipe
    private func connect(to pipePath: String) async -> Bool {
        print("[RPC] Attempting to connect to \(pipePath)")
        
        // Create Unix domain socket
        socketFd = socket(AF_UNIX, SOCK_STREAM, 0)
        guard socketFd >= 0 else {
            print("[RPC] Failed to create socket: \(String(cString: strerror(errno)))")
            return false
        }
        
        // Prepare sockaddr_un structure
        var addr = sockaddr_un()
        addr.sun_family = sa_family_t(AF_UNIX)
        
        // Copy path to sun_path
        let pathCString = pipePath.utf8CString
        guard pathCString.count <= MemoryLayout.size(ofValue: addr.sun_path) else {
            print("[RPC] Path too long")
            Darwin.close(socketFd)
            socketFd = -1
            return false
        }
        
        withUnsafeMutableBytes(of: &addr.sun_path) { ptr in
            pathCString.withUnsafeBytes { pathBytes in
                ptr.copyBytes(from: pathBytes)
            }
        }
        
        // Connect to socket
        let result = withUnsafePointer(to: &addr) { addrPtr in
            addrPtr.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockaddrPtr in
                Darwin.connect(socketFd, sockaddrPtr, socklen_t(MemoryLayout<sockaddr_un>.size))
            }
        }
        
        guard result == 0 else {
            print("[RPC] Failed to connect: \(String(cString: strerror(errno)))")
            Darwin.close(socketFd)
            socketFd = -1
            return false
        }
        
        print("[RPC] Socket connected successfully")
        
        // Send handshake
        if await sendHandshake() {
            // Wait for ready response
            if await waitForReady() {
                isConnected = true
                print("[RPC] Handshake successful, connected!")
                return true
            } else {
                print("[RPC] Handshake failed: didn't receive READY")
            }
        } else {
            print("[RPC] Failed to send handshake")
        }
        
        Darwin.close(socketFd)
        socketFd = -1
        return false
    }
    
    /// Send handshake message
    private func sendHandshake() async -> Bool {
        guard !clientId.isEmpty else {
            print("[RPC] Cannot send handshake: clientId is empty")
            return false
        }
        
        print("[RPC] Sending handshake with clientId: \(clientId)")
        
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
        guard isConnected else {
            print("[RPC] Cannot set activity: not connected")
            return
        }
        
        var activityDict: [String: Any] = [
            "type": activityType.rawValue,
            "instance": false
        ]
        
        print("[RPC] Building activity with type: \(activityType.rawValue)")
        
        if let details = activity.details, !details.isEmpty {
            activityDict["details"] = details
            print("[RPC]   - details: \(details)")
        }
        
        if let state = activity.state, !state.isEmpty {
            activityDict["state"] = state
            print("[RPC]   - state: \(state)")
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
        
        if socketFd >= 0 {
            Darwin.close(socketFd)
            socketFd = -1
        }
        
        isConnected = false
        currentUser = nil
    }
    
    // MARK: - Private Helpers
    
    /// Send a payload to Discord
    private func sendPayload(opcode: RPCOpcode, data: [String: Any]) async -> Bool {
        guard socketFd >= 0 else {
            print("[RPC] Cannot send payload: socket not connected")
            return false
        }
        
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
            
            // Send data
            let sent = packet.withUnsafeBytes { bufferPtr -> Int in
                Darwin.write(socketFd, bufferPtr.baseAddress!, packet.count)
            }
            
            if sent != packet.count {
                print("[RPC] Failed to send complete packet: sent \(sent) of \(packet.count) bytes")
                return false
            }
            
            print("[RPC] Successfully sent \(packet.count) bytes")
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
