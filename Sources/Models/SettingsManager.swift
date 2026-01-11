import Foundation
import Defaults

extension Defaults.Keys {
    // Application settings
    static let clientId = Key<String>("clientId", default: "")
    static let activityType = Key<Int>("activityType", default: 0) // Playing
    
    // Details & State
    static let details = Key<String>("details", default: "")
    static let state = Key<String>("state", default: "")
    
    // Assets
    static let largeImageKey = Key<String>("largeImageKey", default: "")
    static let largeImageText = Key<String>("largeImageText", default: "")
    static let smallImageKey = Key<String>("smallImageKey", default: "")
    static let smallImageText = Key<String>("smallImageText", default: "")
    static let largeImageData = Key<Data?>("largeImageData", default: nil)
    static let smallImageData = Key<Data?>("smallImageData", default: nil)
    
    // Buttons
    static let button1Label = Key<String>("button1Label", default: "")
    static let button1URL = Key<String>("button1URL", default: "")
    static let button2Label = Key<String>("button2Label", default: "")
    static let button2URL = Key<String>("button2URL", default: "")
    
    // Party
    static let partySize = Key<Int>("partySize", default: 0)
    static let partyMax = Key<Int>("partyMax", default: 0)
    
    // Timestamps
    static let timestampMode = Key<String>("timestampMode", default: TimestampMode.sinceStart.rawValue)
    static let customTimestamp = Key<Date?>("customTimestamp", default: nil)
    
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
    
    @Published var activityType: ActivityType = ActivityType(rawValue: Defaults[.activityType]) ?? .playing {
        didSet { Defaults[.activityType] = activityType.rawValue }
    }
    
    // Details & State
    @Published var details: String = Defaults[.details] {
        didSet { Defaults[.details] = details }
    }
    
    @Published var state: String = Defaults[.state] {
        didSet { Defaults[.state] = state }
    }
    
    // Assets
    @Published var largeImageKey: String = Defaults[.largeImageKey] {
        didSet { Defaults[.largeImageKey] = largeImageKey }
    }
    
    @Published var largeImageText: String = Defaults[.largeImageText] {
        didSet { Defaults[.largeImageText] = largeImageText }
    }
    
    @Published var smallImageKey: String = Defaults[.smallImageKey] {
        didSet { Defaults[.smallImageKey] = smallImageKey }
    }
    
    @Published var smallImageText: String = Defaults[.smallImageText] {
        didSet { Defaults[.smallImageText] = smallImageText }
    }
    
    @Published var largeImageData: Data? = Defaults[.largeImageData] {
        didSet { Defaults[.largeImageData] = largeImageData }
    }
    
    @Published var smallImageData: Data? = Defaults[.smallImageData] {
        didSet { Defaults[.smallImageData] = smallImageData }
    }
    
    // Buttons
    @Published var button1Label: String = Defaults[.button1Label] {
        didSet { Defaults[.button1Label] = button1Label }
    }
    
    @Published var button1URL: String = Defaults[.button1URL] {
        didSet { Defaults[.button1URL] = button1URL }
    }
    
    @Published var button2Label: String = Defaults[.button2Label] {
        didSet { Defaults[.button2Label] = button2Label }
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
    
    private init() {}
    
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
        if !button1Label.isEmpty && !button1URL.isEmpty {
            buttons = [RPCButton(label: button1Label, url: button1URL)]
            if !button2Label.isEmpty && !button2URL.isEmpty {
                buttons?.append(RPCButton(label: button2Label, url: button2URL))
            }
        } else if !button2Label.isEmpty && !button2URL.isEmpty {
            buttons = [RPCButton(label: button2Label, url: button2URL)]
        }
        
        var party: RPCParty? = nil
        if partySize > 0 && partyMax > 0 {
            party = RPCParty(id: "drp-idler", size: [partySize, partyMax])
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
        activityType = .playing
        details = ""
        state = ""
        largeImageKey = ""
        largeImageText = ""
        smallImageKey = ""
        smallImageText = ""
        button1Label = ""
        button1URL = ""
        button2Label = ""
        button2URL = ""
        partySize = 0
        partyMax = 0
        timestampMode = .sinceStart
        customTimestamp = nil
    }
}
