import SwiftUI
import LaunchAtLogin

struct MenuBarTab: View {
    @EnvironmentObject var settings: SettingsManager
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Menu Bar Settings")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                // Launch at Login
                Toggle("Launch at Login", isOn: $settings.launchAtLogin)
                    .toggleStyle(.switch)
                    .onChange(of: settings.launchAtLogin) { newValue in
                        LaunchAtLogin.isEnabled = newValue
                    }
                
                Text("Start Discord RPC Idler automatically when you log in to your Mac")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: 400)
            
            Spacer()
        }
        .padding()
    }
}
