import SwiftUI

struct ApplicationTab: View {
    @EnvironmentObject var rpcClient: DiscordRPCClient
    @EnvironmentObject var settings: SettingsManager
    
    var body: some View {
        HStack(spacing: 0) {
            // Left side: Configuration
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                // Client ID Section
                GroupBox {
                    VStack(alignment: .leading, spacing: 6) {
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
                
                // Activity Type
                GroupBox {
                    Picker("", selection: $settings.activityType) {
                        ForEach(ActivityType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                } label: {
                    Text("Activity Type")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                // Details & State
                GroupBox {
                    VStack(spacing: 8) {
                        TextField("What you're doing", text: $settings.details)
                            .textFieldStyle(.roundedBorder)
                        TextField("Additional info", text: $settings.state)
                            .textFieldStyle(.roundedBorder)
                    }
                } label: {
                    Text("Details & State")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                // Images
                GroupBox {
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            TextField("Large Image Key", text: $settings.largeImageKey)
                                .textFieldStyle(.roundedBorder)
                            TextField("Hover Text", text: $settings.largeImageText)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        HStack(spacing: 8) {
                            TextField("Small Image Key", text: $settings.smallImageKey)
                                .textFieldStyle(.roundedBorder)
                            TextField("Hover Text", text: $settings.smallImageText)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                } label: {
                    Text("Images")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                // Buttons
                GroupBox {
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            TextField("Button 1 Label", text: $settings.button1Label)
                                .textFieldStyle(.roundedBorder)
                            TextField("URL", text: $settings.button1URL)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        HStack(spacing: 8) {
                            TextField("Button 2 Label", text: $settings.button2Label)
                                .textFieldStyle(.roundedBorder)
                            TextField("URL", text: $settings.button2URL)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                } label: {
                    Text("Buttons (max 2)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                // Party & Timestamps
                HStack(spacing: 12) {
                    GroupBox {
                        HStack(spacing: 8) {
                            TextField("Size", value: $settings.partySize, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 50)
                            Text("/")
                            TextField("Max", value: $settings.partyMax, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 50)
                        }
                    } label: {
                        Text("Party")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    
                    GroupBox {
                        VStack(alignment: .leading, spacing: 4) {
                            Picker("", selection: $settings.timestampMode) {
                                ForEach(TimestampMode.allCases, id: \.self) { mode in
                                    Text(mode.displayName).tag(mode)
                                }
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                            
                            if settings.timestampMode == .custom {
                                DatePicker("", selection: Binding(
                                    get: { settings.customTimestamp ?? Date() },
                                    set: { settings.customTimestamp = $0 }
                                ), displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                                .labelsHidden()
                            }
                        }
                    } label: {
                        Text("Timestamps")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
                
                // Update Button
                Button(action: updatePresence) {
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                        Text("Update Presence")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(settings.clientId.isEmpty)
                .controlSize(.large)
                }
                .padding()
            }
            .frame(width: 500)
            
            Divider()
            
            // Right side: Preview
            VStack(spacing: 20) {
                Text("Discord Activity Preview")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                // Discord Message Card Preview
                VStack(alignment: .leading, spacing: 0) {
                    // User Header
                    HStack(spacing: 10) {
                        Circle()
                            .fill(Color.blue.opacity(0.3))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.blue)
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text("YourUsername")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("BOT")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 2)
                                    .background(Color.blue)
                                    .cornerRadius(3)
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                    
                    // Activity Content
                    HStack(alignment: .top, spacing: 10) {
                        // Image
                        if !settings.largeImageKey.isEmpty {
                            ZStack(alignment: .bottomTrailing) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.gray.opacity(0.15))
                                    .frame(width: 70, height: 70)
                                    .overlay(
                                        VStack(spacing: 2) {
                                            Image(systemName: "photo")
                                                .font(.system(size: 20))
                                                .foregroundColor(.gray)
                                            Text(settings.largeImageKey.prefix(8))
                                                .font(.system(size: 8))
                                                .foregroundColor(.gray)
                                        }
                                    )
                                
                                if !settings.smallImageKey.isEmpty {
                                    Circle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 22, height: 22)
                                        .overlay(
                                            Image(systemName: "circle.fill")
                                                .font(.system(size: 10))
                                                .foregroundColor(.green)
                                        )
                                        .offset(x: 6, y: 6)
                                }
                            }
                        }
                        
                        // Details
                        VStack(alignment: .leading, spacing: 3) {
                            Text(settings.activityType.displayName)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.secondary)
                            
                            if !settings.details.isEmpty {
                                Text(settings.details)
                                    .font(.system(size: 13, weight: .semibold))
                                    .lineLimit(2)
                            }
                            
                            if !settings.state.isEmpty {
                                Text(settings.state)
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                            
                            if settings.partySize > 0 && settings.partyMax > 0 {
                                Text("\(settings.partySize) of \(settings.partyMax)")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                            
                            if settings.timestampMode != .none {
                                Text("00:00:00 elapsed")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
                    
                    // Buttons
                    if (!settings.button1Label.isEmpty && !settings.button1URL.isEmpty) ||
                       (!settings.button2Label.isEmpty && !settings.button2URL.isEmpty) {
                        VStack(spacing: 6) {
                            if !settings.button1Label.isEmpty && !settings.button1URL.isEmpty {
                                HStack {
                                    Text(settings.button1Label)
                                        .font(.system(size: 12, weight: .medium))
                                    Spacer()
                                }
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(Color.gray.opacity(0.15))
                                .cornerRadius(4)
                            }
                            
                            if !settings.button2Label.isEmpty && !settings.button2URL.isEmpty {
                                HStack {
                                    Text(settings.button2Label)
                                        .font(.system(size: 12, weight: .medium))
                                    Spacer()
                                }
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(Color.gray.opacity(0.15))
                                .cornerRadius(4)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.bottom, 12)
                    }
                }
                .frame(maxWidth: 320)
                .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                
                Text("Updates live
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
    }
    
    private func updatePresence() {
        let presence = settings.buildRichPresence(rpcClient: rpcClient)
        Task {
            await rpcClient.setActivity(presence, activityType: settings.activityType)
        }
    }
}
