import SwiftUI

struct PreviewTab: View {
    @EnvironmentObject var settings: SettingsManager
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Discord Activity Preview")
                .font(.title2)
                .fontWeight(.semibold)
            
            // Discord Message Card Mockup
            HStack(alignment: .top, spacing: 16) {
                // Avatar
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                    )
                
                VStack(alignment: .leading, spacing: 8) {
                    // Username with Bot badge
                    HStack(spacing: 8) {
                        Text("YourUsername")
                            .font(.headline)
                        
                        Text("BOT")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue)
                            .cornerRadius(4)
                    }
                    
                    // Activity Card
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .top, spacing: 12) {
                            // Large Image
                            if !settings.largeImageKey.isEmpty {
                                ZStack(alignment: .bottomTrailing) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 80, height: 80)
                                        .overlay(
                                            Text(settings.largeImageKey)
                                                .font(.caption2)
                                                .multilineTextAlignment(.center)
                                                .padding(4)
                                        )
                                    
                                    // Small Image overlay
                                    if !settings.smallImageKey.isEmpty {
                                        Circle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 24, height: 24)
                                            .overlay(
                                                Text(settings.smallImageKey.prefix(2))
                                                    .font(.system(size: 8))
                                            )
                                            .offset(x: 8, y: 8)
                                    }
                                }
                            }
                            
                            // Activity Details
                            VStack(alignment: .leading, spacing: 4) {
                                Text(settings.activityType.displayName)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                                
                                if !settings.details.isEmpty {
                                    Text(settings.details)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                
                                if !settings.state.isEmpty {
                                    Text(settings.state)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                if settings.partySize > 0 && settings.partyMax > 0 {
                                    Text("\(settings.partySize) of \(settings.partyMax)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                if settings.timestampMode != .none {
                                    Text("Elapsed: 00:00:00")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding()
                        
                        // Buttons
                        if (!settings.button1Label.isEmpty && !settings.button1URL.isEmpty) ||
                           (!settings.button2Label.isEmpty && !settings.button2URL.isEmpty) {
                            VStack(spacing: 8) {
                                if !settings.button1Label.isEmpty && !settings.button1URL.isEmpty {
                                    Button(action: {}) {
                                        Text(settings.button1Label)
                                            .font(.caption)
                                            .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(.bordered)
                                }
                                
                                if !settings.button2Label.isEmpty && !settings.button2URL.isEmpty {
                                    Button(action: {}) {
                                        Text(settings.button2Label)
                                            .font(.caption)
                                            .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom)
                        }
                    }
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: 500)
            .background(Color(NSColor.textBackgroundColor))
            .cornerRadius(12)
            .shadow(radius: 2)
            
            Text("This is a preview of how your activity will appear in Discord")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
    }
}
