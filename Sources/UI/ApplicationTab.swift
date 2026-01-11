import SwiftUI

public struct ApplicationTab: View {
    @EnvironmentObject var rpcClient: DiscordRPCClient
    @EnvironmentObject var settings: SettingsManager
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var startTime = Date()
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {

                    // Activity Type Badge
                    Text(settings.activityType.displayName)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.6))
                        .cornerRadius(4)
                        .padding(1)
                    
                    HStack(alignment: .top, spacing: 12) {
                        // Large Image Placeholder
                        ZStack(alignment: .bottomTrailing) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 80, height: 80)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            // Application Name
                            if !settings.appName.isEmpty {
                                Text(settings.appName)
                                    .font(.system(size: 14, weight: .semibold))
                            }

                            // Details
                            if !settings.details.isEmpty {
                                Text(settings.details)
                                    .font(.system(size: 13))
                                    .foregroundColor(.primary)
                            }

                            // State
                            if !settings.state.isEmpty {
                                Text(settings.state)
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }

                            // Elapsed Time
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.system(size: 11))
                                Text(formatElapsedTime(elapsedTime))
                                    .font(.system(size: 13))
                            }
                            .foregroundColor(.secondary)

                            // Party Info
                            if settings.partySize > 0 && settings.partyMax > 0 {
                                HStack(spacing: 4) {
                                    Image(systemName: "person.2.fill")
                                        .font(.system(size: 11))
                                    Text("In a party (\(settings.partySize) of \(settings.partyMax))")
                                        .font(.system(size: 13))
                                }
                                .foregroundColor(.secondary)
                            }
                        }
                    }

                    // Button
                    if !settings.button1Text.isEmpty {
                        Button(action: {}) {
                            Text(settings.button1Text)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.4))
                                .cornerRadius(4)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor).opacity(0.6))
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                Divider()
                
                // Settings Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Settings")
                        .font(.system(size: 16, weight: .semibold))
                    
                    // Activity Type
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Activity Type")
                            .font(.system(size: 13, weight: .medium))
                        
                        Picker("", selection: $settings.activityType) {
                            ForEach(ActivityType.allCases, id: \.self) { type in
                                Text(type.displayName).tag(type)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                    }
                    
                    // Application Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Application Name")
                            .font(.system(size: 13, weight: .medium))
                        TextField("Enter application name", text: $settings.appName)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    // Detail (line 1)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Detail (line 1)")
                            .font(.system(size: 13, weight: .medium))
                        TextField("What you're doing", text: $settings.details)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    // State (line 2)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("State (line 2)")
                            .font(.system(size: 13, weight: .medium))
                        TextField("Additional info", text: $settings.state)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    // Stream Link
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Stream Link (Twitch or YouTube, only if activity type is Streaming)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                        TextField("Enter a value", text: $settings.streamURL)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    // Party Size & Maximum Party Size
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Party Size")
                                .font(.system(size: 13, weight: .medium))
                            TextField("1", text: Binding(
                                get: { settings.partySize > 0 ? "\(settings.partySize)" : "" },
                                set: { settings.partySize = Int($0) ?? 0 }
                            ))
                            .textFieldStyle(.roundedBorder)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Maximum Party Size")
                                .font(.system(size: 13, weight: .medium))
                            TextField("99999999", text: Binding(
                                get: { settings.partyMax > 0 ? "\(settings.partyMax)" : "" },
                                set: { settings.partyMax = Int($0) ?? 0 }
                            ))
                            .textFieldStyle(.roundedBorder)
                        }
                    }
                }
            }
            .padding()
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func startTimer() {
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedTime = Date().timeIntervalSince(startTime)
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func formatElapsedTime(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = Int(interval) / 60 % 60
        let seconds = Int(interval) % 60
        return String(format: "%d:%02d:%02d elapsed", hours, minutes, seconds)
    }
}

struct ApplicationTab_Previews: PreviewProvider {
    static var previews: some View {
        let previewSettings = SettingsManager.shared
        previewSettings.appName = "World of Warcraft Classic"
        previewSettings.details = "Raiding Hogger"
        previewSettings.state = "In a party"
        previewSettings.streamURL = "https://www.twitch.tv/example"
        previewSettings.partySize = 1
        previewSettings.partyMax = 5
        previewSettings.activityType = .playing
        
        return ApplicationTab()
            .environmentObject(DiscordRPCClient())
            .environmentObject(previewSettings)
            .frame(width: 600, height: 800)
    }
}

