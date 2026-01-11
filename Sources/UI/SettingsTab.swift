import SwiftUI
import LaunchAtLogin

public struct SettingsTab: View {
    @EnvironmentObject var rpcClient: DiscordRPCClient
    @EnvironmentObject var settings: SettingsManager
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading ,spacing: 20) {
                // Launch at Login
                GroupBox {
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("Launch at Login", isOn: $settings.launchAtLogin)
                            .toggleStyle(.switch)
                            .onChange(of: settings.launchAtLogin) { newValue in
                                LaunchAtLogin.isEnabled = newValue
                            }
                        
                        Text("Start DiscordRPC-Idler automatically when you log in to your Mac")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } label: {
                    Text("Client Settings")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                
            }
            .padding()
        }
    }
}

struct SettingsTab_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTab()
            .environmentObject(DiscordRPCClient())
            .environmentObject(SettingsManager.shared)
            .frame(width: 500, height: 250)
    }
}

