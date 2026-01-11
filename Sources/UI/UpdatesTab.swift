import SwiftUI
import Sparkle

public struct UpdatesTab: View {
    @EnvironmentObject var settings: SettingsManager
    // Disable auto-start during development
    private let updaterController = SPUStandardUpdaterController(startingUpdater: false, updaterDelegate: nil, userDriverDelegate: nil)
    
    let frequencies = ["Daily", "Weekly", "Monthly"]
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            VStack(alignment: .leading, spacing: 8) {
                // Check for Updates
                HStack(spacing: 16) {
                    Text("Check for Updates")
                        .frame(width: 140, alignment: .trailing)
                    
                    Toggle("", isOn: $settings.autoCheckUpdates)
                        .labelsHidden()
                        .toggleStyle(.switch)
                    
                    Text("Enable")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Frequency
                HStack(spacing: 8) {
                    Text("Frequency")
                        .frame(width: 140, alignment: .trailing)
                    
                    Picker("", selection: $settings.updateFrequency) {
                        ForEach(frequencies, id: \.self) { frequency in
                            Text(frequency).tag(frequency)
                        }
                    }
                    .pickerStyle(.menu)
                    .disabled(!settings.autoCheckUpdates)
                    
                    Button("Check Now") {
                        updaterController.checkForUpdates(nil)
                    }
                    .disabled(!settings.autoCheckUpdates)
                    
                    Spacer()
                }
                
                Divider()
                    .padding(.vertical, 8)
                
                // Options
                HStack(spacing: 16) {
                    Text("Options")
                        .frame(width: 140, alignment: .trailing)
                    
                    Toggle("", isOn: $settings.autoDownloadUpdates)
                        .labelsHidden()
                        .toggleStyle(.switch)
                    
                    Text("Automatically download new updates")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: 500)
            
            Spacer()
        }
        .padding()
    }
}

struct UpdatesTab_Previews: PreviewProvider {
    static var previews: some View {
        UpdatesTab()
            .environmentObject(SettingsManager.shared)
            .frame(width: 500, height: 300)
    }
}
