import SwiftUI

public enum AppTab: Int {
    case application = 0
    case settings = 1
    case updates = 2
    
    var windowSize: CGSize {
        switch self {
        case .application:
            return CGSize(width: 600, height: 650)
        case .settings:
            return CGSize(width: 500, height: 300)
        case .updates:
            return CGSize(width: 500, height: 300)
        }
    }
}

public struct SettingsView: View {
    @EnvironmentObject var rpcClient: DiscordRPCClient
    @StateObject private var settings = SettingsManager.shared
    @State private var selectedTab: AppTab = .application
    @State private var settingsWindow: NSWindow?
    
    public init() {}
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            ApplicationTab()
                .tabItem {
                    Label("Application", systemImage: "app.dashed")
                }
                .tag(AppTab.application)
            
            SettingsTab()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(AppTab.settings)
            
            UpdatesTab()
                .tabItem {
                    Label("Updates", systemImage: "arrow.triangle.2.circlepath.circle")
                }
                .tag(AppTab.updates)
        }
        .onChange(of: selectedTab) { newTab in
            resizeWindow(to: newTab.windowSize)
        }
        .environmentObject(settings)
        .onAppear {
            // Find our settings window immediately
            if let window = NSApplication.shared.windows.first(where: { $0.title == "DiscordRPC-Idler Settings" }) {
                settingsWindow = window
                // Set initial size based on current tab
                resizeWindow(to: selectedTab.windowSize, animated: false)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SettingsWindowCreated"))) { notification in
            if let window = notification.object as? NSWindow {
                settingsWindow = window
                // Set size immediately after window creation
                resizeWindow(to: selectedTab.windowSize, animated: false)
            }
        }
    }
    
    private func resizeWindow(to size: CGSize, animated: Bool = true) {
        guard let window = settingsWindow else { return }
        
        // Keep top-left corner fixed
        let newFrame = NSRect(
            x: window.frame.origin.x,
            y: window.frame.origin.y + (window.frame.height - size.height),
            width: size.width,
            height: size.height
        )
        
        if animated {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.15
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                context.allowsImplicitAnimation = true
                window.animator().setFrame(newFrame, display: true, animate: true)
            })
        } else {
            window.setFrame(newFrame, display: true, animate: false)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(DiscordRPCClient())
            .frame(width: 600, height: 650)
    }
}
