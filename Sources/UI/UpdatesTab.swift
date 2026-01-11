import SwiftUI
import Sparkle

struct UpdatesTab: View {
    @EnvironmentObject var settings: SettingsManager
    private let updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
    
    let frequencies = ["Daily", "Weekly", "Monthly"]
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Update Settings")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                // Check for Updates Toggle
                Toggle("Check for Updates", isOn: $settings.autoCheckUpdates)
                    .toggleStyle(.switch)
                
                // Frequency Picker
                HStack {
                    Text("Frequency")
                        .frame(width: 100, alignment: .leading)
                    
                    Picker("", selection: $settings.updateFrequency) {
                        ForEach(frequencies, id: \.self) { frequency in
                            Text(frequency).tag(frequency)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 150)
                    .disabled(!settings.autoCheckUpdates)
                }
                
                // Check Now Button
                Button("Check Now") {
                    updaterController.checkForUpdates(nil)
                }
                .disabled(!settings.autoCheckUpdates)
            }
            .frame(maxWidth: 400)
            
            Spacer()
        }
        .padding()
    }
}
