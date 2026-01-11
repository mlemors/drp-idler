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
            
            PreviewTab()
                .tabItem {
                    Label("Preview", systemImage: "eye")
                }
            
            MenuBarTab()
                .tabItem {
                    Label("Menu Bar", systemImage: "menubar.rectangle")
                }
            
            UpdatesTab()
                .tabItem {
                    Label("Updates", systemImage: "arrow.triangle.2.circlepath.circle")
                }
        }
        .frame(width: 700, height: 550)
        .environmentObject(settings)
    }
}
