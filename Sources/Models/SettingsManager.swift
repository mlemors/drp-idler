import Foundation
import Defaults

extension Defaults.Keys {
    // Application settings
    static let clientId = Key<String>("clientId", default: "")
    static let appName = Key<String>("appName", default: "")
    static let activityType = Key<Int>("activityType", default: 0) // Playing
    
    // Details & State
    static let details = Key<String>("details", default: "")
    static let detailsURL = Key<String>("detailsURL", default: "")
    static let state = Key<String>("state", default: "")
    static let stateURL = Key<String>("stateURL", default: "")
    static let streamURL = Key<String>("streamURL", default: "")
    
    // Assets
    static let largeImageKey = Key<String>("largeImageKey", default: "")
    static let largeImageText = Key<String>("largeImageText", default: "")
    static let largeImageURL = Key<String>("largeImageURL", default: "")
    static let smallImageKey = Key<String>("smallImageKey", default: "")
    static let smallImageText = Key<String>("smallImageText", default: "")
    static let smallImageURL = Key<String>("smallImageURL", default: "")
    static let largeImageData = Key<Data?>("largeImageData", default: nil)
    static let smallImageData = Key<Data?>("smallImageData", default: nil)
    
    // Buttons
    static let button1Text = Key<String>("button1Text", default: "")
    static let button1URL = Key<String>("button1URL", default: "")
    static let button2Text = Key<String>("button2Text", default: "")
    static let button2URL = Key<String>("button2URL", default: "")
    
    // Party
    static let partySize = Key<Int>("partySize", default: 0)
    static let partyMax = Key<Int>("partyMax", default: 0)
    
    // Timestamps
    static let timestampMode = Key<String>("timestampMode", default: TimestampMode.sinceStart.rawValue)
    static let customTimestamp = Key<Date?>("customTimestamp", default: nil)
    static let customEndTimestamp = Key<Date?>("customEndTimestamp", default: nil)
    
    // Menu Bar settings
    static let launchAtLogin = Key<Bool>("launchAtLogin", default: false)
    
    // Update settings
    static let autoCheckUpdates = Key<Bool>("autoCheckUpdates", default: true)
    static let updateFrequency = Key<String>("updateFrequency", default: "Daily")
    static let autoDownloadUpdates = Key<Bool>("autoDownloadUpdates", default: true)
}

/// Settings Manager - provides convenient access to all settings
@MainActor
class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    // Application
    @Published var clientId: String = Defaults[.clientId] {
        didSet { Defaults[.clientId] = clientId }
    }
    
    @Published var appName: String = Defaults[.appName] {
        didSet { Defaults[.appName] = appName }
    }
    
    @Published var activityType: ActivityType = ActivityType(rawValue: Defaults[.activityType]) ?? .playing {
        didSet { Defaults[.activityType] = activityType.rawValue }
    }
    
    // Details & State
    @Published var details: String = Defaults[.details] {
        didSet { Defaults[.details] = details }
    }
    
    @Published var detailsURL: String = Defaults[.detailsURL] {
        didSet { Defaults[.detailsURL] = detailsURL }
    }
    
    @Published var state: String = Defaults[.state] {
        didSet { Defaults[.state] = state }
    }
    
    @Published var stateURL: String = Defaults[.stateURL] {
        didSet { Defaults[.stateURL] = stateURL }
    }
    
    @Published var streamURL: String = Defaults[.streamURL] {
        didSet { Defaults[.streamURL] = streamURL }
    }
    
    // Assets
    @Published var largeImageKey: String = Defaults[.largeImageKey] {
        didSet { Defaults[.largeImageKey] = largeImageKey }
    }
    
    @Published var largeImageText: String = Defaults[.largeImageText] {
        didSet { Defaults[.largeImageText] = largeImageText }
    }
    
    @Published var largeImageURL: String = Defaults[.largeImageURL] {
        didSet { Defaults[.largeImageURL] = largeImageURL }
    }
    
    @Published var smallImageKey: String = Defaults[.smallImageKey] {
        didSet { Defaults[.smallImageKey] = smallImageKey }
    }
    
    @Published var smallImageText: String = Defaults[.smallImageText] {
        didSet { Defaults[.smallImageText] = smallImageText }
    }
    
    @Published var smallImageURL: String = Defaults[.smallImageURL] {
        didSet { Defaults[.smallImageURL] = smallImageURL }
    }
    
    @Published var largeImageData: Data? = Defaults[.largeImageData] {
        didSet { Defaults[.largeImageData] = largeImageData }
    }
    
    @Published var smallImageData: Data? = Defaults[.smallImageData] {
        didSet { Defaults[.smallImageData] = smallImageData }
    }
    
    // Buttons
    @Published var button1Text: String = Defaults[.button1Text] {
        didSet { Defaults[.button1Text] = button1Text }
    }
    
    @Published var button1URL: String = Defaults[.button1URL] {
        didSet { Defaults[.button1URL] = button1URL }
    }
    
    @Published var button2Text: String = Defaults[.button2Text] {
        didSet { Defaults[.button2Text] = button2Text }
    }
    
    @Published var button2URL: String = Defaults[.button2URL] {
        didSet { Defaults[.button2URL] = button2URL }
    }
    
    // Party
    @Published var partySize: Int = Defaults[.partySize] {
        didSet { Defaults[.partySize] = partySize }
    }
    
    @Published var partyMax: Int = Defaults[.partyMax] {
        didSet { Defaults[.partyMax] = partyMax }
    }
    
    // Timestamps
    @Published var timestampMode: TimestampMode = TimestampMode(rawValue: Defaults[.timestampMode]) ?? .sinceStart {
        didSet { Defaults[.timestampMode] = timestampMode.rawValue }
    }
    
    @Published var customTimestamp: Date? = Defaults[.customTimestamp] {
        didSet { Defaults[.customTimestamp] = customTimestamp }
    }
    
    @Published var customEndTimestamp: Date? = Defaults[.customEndTimestamp] {
        didSet { Defaults[.customEndTimestamp] = customEndTimestamp }
    }
    
    // Menu Bar
    @Published var launchAtLogin: Bool = Defaults[.launchAtLogin] {
        didSet { Defaults[.launchAtLogin] = launchAtLogin }
    }
    
    // Updates
    @Published var autoCheckUpdates: Bool = Defaults[.autoCheckUpdates] {
        didSet { Defaults[.autoCheckUpdates] = autoCheckUpdates }
    }
    
    @Published var updateFrequency: String = Defaults[.updateFrequency] {
        didSet { Defaults[.updateFrequency] = updateFrequency }
    }
    
    @Published var autoDownloadUpdates: Bool = Defaults[.autoDownloadUpdates] {
        didSet { Defaults[.autoDownloadUpdates] = autoDownloadUpdates }
    }
    
    private init() {
        // Load Client ID from environment if available (for testing)
        if clientId.isEmpty {
            if let envClientId = ProcessInfo.processInfo.environment["DISCORD_CLIENT_ID"], !envClientId.isEmpty {
                clientId = envClientId
            }
        }
    }
    
    /// Build RichPresence from current settings
    func buildRichPresence(rpcClient: DiscordRPCClient) -> RichPresence {
        var assets: RPCAssets? = nil
        if !largeImageKey.isEmpty || !smallImageKey.isEmpty {
            assets = RPCAssets(
                largeImage: largeImageKey.isEmpty ? nil : largeImageKey,
                largeText: largeImageText.isEmpty ? nil : largeImageText,
                smallImage: smallImageKey.isEmpty ? nil : smallImageKey,
                smallText: smallImageText.isEmpty ? nil : smallImageText
            )
        }
        
        var buttons: [RPCButton]? = nil
        if !button1Text.isEmpty && !button1URL.isEmpty {
            buttons = [RPCButton(label: button1Text, url: button1URL)]
            if !button2Text.isEmpty && !button2URL.isEmpty {
                buttons?.append(RPCButton(label: button2Text, url: button2URL))
            }
        } else if !button2Text.isEmpty && !button2URL.isEmpty {
            buttons = [RPCButton(label: button2Text, url: button2URL)]
        }
        
        var party: RPCParty? = nil
        if partySize > 0 && partyMax > 0 {
            party = RPCParty(id: "discordrpc-idler", size: [partySize, partyMax])
        }
        
        let timestamps = rpcClient.getTimestamp(mode: timestampMode, customTimestamp: customTimestamp)
        
        return RichPresence(
            details: details.isEmpty ? nil : details,
            state: state.isEmpty ? nil : state,
            timestamps: timestamps,
            assets: assets,
            party: party,
            buttons: buttons
        )
    }
    
    /// Reset all settings to default
    func resetToDefaults() {
        clientId = ""
        appName = ""
        activityType = .playing
        details = ""
        detailsURL = ""
        state = ""
        stateURL = ""
        streamURL = ""
        largeImageKey = ""
        largeImageText = ""
        largeImageURL = ""
        smallImageKey = ""
        smallImageText = ""
        smallImageURL = ""
        button1Text = ""
        button1URL = ""
        button2Text = ""
        button2URL = ""
        partySize = 0
        partyMax = 0
        timestampMode = .sinceStart
        customTimestamp = nil
        customEndTimestamp = nil
    }
}
