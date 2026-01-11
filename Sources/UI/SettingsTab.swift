import SwiftUI
import LaunchAtLogin

public struct SettingsTab: View {
    @EnvironmentObject var rpcClient: DiscordRPCClient
    @EnvironmentObject var settings: SettingsManager
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading ,spacing: 20) {
                // Client ID
                GroupBox {
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Discord Application ID", text: $settings.clientId)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: settings.clientId) { newValue in
                                rpcClient.updateClientId(newValue)
                            }
                        
                        HStack(spacing: 4) {
                            Text("Get ID from")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Link("discord.com/developers", destination: URL(string: "https://discord.com/developers/applications")!)
                                .font(.caption)
                        }
                    }
                } label: {
                    Text("Client ID")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                Divider()
                    .padding(.vertical, 8)
                
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

