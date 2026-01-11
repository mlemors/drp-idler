import SwiftUI
import AppKit

public struct DiscordRPCIdlerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    public init() {}
    
    public var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
