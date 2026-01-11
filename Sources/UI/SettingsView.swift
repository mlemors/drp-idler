import SwiftUI

enum SettingsTab: String, CaseIterable {
    case application = "Application"
    case settings = "Settings"
    case updates = "Updates"
    
    var icon: String {
        switch self {
        case .application: return "app.dashed"
        case .settings: return "gearshape"
        case .updates: return "arrow.triangle.2.circlepath.circle"
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var rpcClient: DiscordRPCClient
    @StateObject private var settings = SettingsManager.shared
    @State private var selectedTab: SettingsTab = .application
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Tab Bar
            HStack(spacing: 20) {
                ForEach(SettingsTab.allCases, id: \.self) { tab in
                    Button(action: {
                        selectedTab = tab
                    }) {
                        VStack(spacing: 6) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 28))
                                .frame(width: 50, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedTab == tab ? Color.accentColor.opacity(0.2) : Color.clear)
                                )
                            
                            Text(tab.rawValue)
                                .font(.caption)
                                .foregroundColor(selectedTab == tab ? .primary : .secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Content
            Group {
                switch selectedTab {
                case .application:
                    ApplicationTab()
                case .settings:
                    MenuBarTab()
                case .updates:
                    UpdatesTab()
                }
            }
        }
        .environmentObject(settings)
    }
}
