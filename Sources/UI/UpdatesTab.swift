import SwiftUI
import Sparkle

struct UpdatesTab: View {
    @EnvironmentObject var settings: SettingsManager
    // Disable auto-start during development
    private let updaterController = SPUStandardUpdaterController(startingUpdater: false, updaterDelegate: nil, userDriverDelegate: nil)
    
    let frequencies = ["Daily", "Weekly", "Monthly"]
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(alignment: .leading, spacing: 20) {
                // Check for Updates
                HStack(spacing: 20) {
                    Text("Check for Updates")
                        .frame(width: 180, alignment: .trailing)
                    
                    Toggle("", isOn: $settings.autoCheckUpdates)
                        .labelsHidden()
                        .toggleStyle(.switch)
                    
                    Text("Enable")
                    
                    Spacer()
                }
                
                // Frequency
                HStack(spacing: 20) {
                    Text("Frequency")
                        .frame(width: 180, alignment: .trailing)
                    
                    Picker("", selection: $settings.updateFrequency) {
                        ForEach(frequencies, id: \.self) { frequency in
                            Text(frequency).tag(frequency)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 150)
                    .disabled(!settings.autoCheckUpdates)
                    
                    Spacer()
                }
                
                // Check Now Button
                HStack(spacing: 20) {
                    Spacer()
                        .frame(width: 180)
                    
                    Button("Check Now") {
                        updaterController.checkForUpdates(nil)
                    }
                    .disabled(!settings.autoCheckUpdates)
                    
                    Spacer()
                }
                
                Divider()
                    .padding(.vertical, 10)
                
                // Options
                HStack(spacing: 20) {
                    Text("Options")
                        .frame(width: 180, alignment: .trailing)
                    
                    Toggle("", isOn: $settings.autoDownloadUpdates)
                        .labelsHidden()
                        .toggleStyle(.switch)
                    
                    Text("Automatically download new updates")
                    
                    Spacer()
                }
            }
            .frame(maxWidth: 600)
            
            Spacer()
        }
        .padding()
    }
}
