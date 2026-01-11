import Foundation

/// Discord RPC Activity Types
public enum ActivityType: Int, Codable, CaseIterable {
    case playing = 0
    case streaming = 1
    case listening = 2
    case watching = 3
    case custom = 4
    case competing = 5
    
    public var displayName: String {
        switch self {
        case .playing: return "Playing"
        case .streaming: return "Streaming"
        case .listening: return "Listening to"
        case .watching: return "Watching"
        case .custom: return "Custom"
        case .competing: return "Competing in"
        }
    }
}

/// Timestamp configuration
public enum TimestampMode: String, Codable, CaseIterable {
    case none = "None"
    case sinceStart = "Since App Start"
    case custom = "Custom"
    
    public var displayName: String { rawValue }
}

/// Rich Presence Assets
struct RPCAssets: Codable {
    var largeImage: String?
    var largeText: String?
    var smallImage: String?
    var smallText: String?
    
    enum CodingKeys: String, CodingKey {
        case largeImage = "large_image"
        case largeText = "large_text"
        case smallImage = "small_image"
        case smallText = "small_text"
    }
}

/// Rich Presence Button
struct RPCButton: Codable {
    var label: String
    var url: String
}

/// Rich Presence Timestamps
struct RPCTimestamps: Codable {
    var start: Int?
    var end: Int?
}

/// Rich Presence Party
struct RPCParty: Codable {
    var id: String?
    var size: [Int]?
}

/// Complete Rich Presence Activity
struct RichPresence: Codable {
    var details: String?
    var state: String?
    var timestamps: RPCTimestamps?
    var assets: RPCAssets?
    var party: RPCParty?
    var buttons: [RPCButton]?
    var instance: Bool?
    
    init(
        details: String? = nil,
        state: String? = nil,
        timestamps: RPCTimestamps? = nil,
        assets: RPCAssets? = nil,
        party: RPCParty? = nil,
        buttons: [RPCButton]? = nil
    ) {
        self.details = details
        self.state = state
        self.timestamps = timestamps
        self.assets = assets
        self.party = party
        self.buttons = buttons
        self.instance = false
    }
}

/// RPC Command types
enum RPCCommand: String {
    case dispatch = "DISPATCH"
    case authorize = "AUTHORIZE"
    case authenticate = "AUTHENTICATE"
    case setActivity = "SET_ACTIVITY"
    case subscribe = "SUBSCRIBE"
    case unsubscribe = "UNSUBSCRIBE"
}

/// RPC Event types
enum RPCEvent: String {
    case ready = "READY"
    case error = "ERROR"
}

/// RPC Opcodes
enum RPCOpcode: Int32 {
    case handshake = 0
    case frame = 1
    case close = 2
    case ping = 3
    case pong = 4
}

/// RPC Payload structure
struct RPCPayload: Codable {
    var cmd: String?
    var evt: String?
    var nonce: String?
    var args: AnyCodable?
    var data: AnyCodable?
}

/// Helper to encode/decode Any values
struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            value = dict.mapValues { $0.value }
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else {
            value = NSNull()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let bool as Bool:
            try container.encode(bool)
        case let dict as [String: Any]:
            try container.encode(dict.mapValues { AnyCodable($0) })
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        default:
            try container.encodeNil()
        }
    }
}
