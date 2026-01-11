import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var rpcClient: DiscordRPCClient
    @StateObject private var settings = SettingsManager.shared
    
    var body: some View {
        TabView {
            ApplicationTab()
                .tabItem {
                    Label("Application", systemImage: "app.dashed")
                }
            
            MenuBarTab()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
            
            UpdatesTab()
                .tabItem {
                    Label("Updates", systemImage: "arrow.triangle.2.circlepath.circle")
                }
        }
        .environmentObject(settings)
    }
}
