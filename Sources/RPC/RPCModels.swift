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
public struct RPCAssets: Codable {
    public var largeImage: String?
    public var largeText: String?
    public var smallImage: String?
    public var smallText: String?
    
    public init(largeImage: String? = nil, largeText: String? = nil, smallImage: String? = nil, smallText: String? = nil) {
        self.largeImage = largeImage
        self.largeText = largeText
        self.smallImage = smallImage
        self.smallText = smallText
    }
    
    enum CodingKeys: String, CodingKey {
        case largeImage = "large_image"
        case largeText = "large_text"
        case smallImage = "small_image"
        case smallText = "small_text"
    }
}

/// Rich Presence Button
public struct RPCButton: Codable {
    public var label: String
    public var url: String
    
    public init(label: String, url: String) {
        self.label = label
        self.url = url
    }
}

/// Rich Presence Timestamps
public struct RPCTimestamps: Codable {
    public var start: Int?
    public var end: Int?
    
    public init(start: Int? = nil, end: Int? = nil) {
        self.start = start
        self.end = end
    }
}

/// Rich Presence Party
public struct RPCParty: Codable {
    public var id: String?
    public var size: [Int]?
    
    public init(id: String? = nil, size: [Int]? = nil) {
        self.id = id
        self.size = size
    }
}

/// Complete Rich Presence Activity
public struct RichPresence: Codable {
    public var details: String?
    public var state: String?
    public var timestamps: RPCTimestamps?
    public var assets: RPCAssets?
    public var party: RPCParty?
    public var buttons: [RPCButton]?
    public var instance: Bool?
    
    public init(
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
