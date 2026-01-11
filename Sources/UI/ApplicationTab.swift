import SwiftUI

struct ApplicationTab: View {
    @EnvironmentObject var rpcClient: DiscordRPCClient
    @EnvironmentObject var settings: SettingsManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Client ID Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Client ID")
                        .font(.headline)
                    
                    TextField("Enter your Discord Application ID", text: $settings.clientId)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: settings.clientId) { newValue in
                            rpcClient.updateClientId(newValue)
                        }
                    
                    HStack(spacing: 4) {
                        Text("Create your application at")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Link("discord.com/developers/applications", destination: URL(string: "https://discord.com/developers/applications")!)
                            .font(.caption)
                    }
                }
                
                Divider()
                
                // Activity Type
                VStack(alignment: .leading, spacing: 8) {
                    Text("Activity Type")
                        .font(.headline)
                    
                    Picker("Type", selection: $settings.activityType) {
                        ForEach(ActivityType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Divider()
                
                // Details & State
                VStack(alignment: .leading, spacing: 12) {
                    Text("Activity Information")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Details")
                            .font(.subheadline)
                        TextField("What you're doing", text: $settings.details)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("State")
                            .font(.subheadline)
                        TextField("Additional info", text: $settings.state)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                
                Divider()
                
                // Images
                VStack(alignment: .leading, spacing: 12) {
                    Text("Images")
                        .font(.headline)
                    
                    HStack(spacing: 20) {
                        // Large Image
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Large Image")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("Image Key", text: $settings.largeImageKey)
                                .textFieldStyle(.roundedBorder)
                            
                            TextField("Hover Text", text: $settings.largeImageText)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        // Small Image
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Small Image")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("Image Key", text: $settings.smallImageKey)
                                .textFieldStyle(.roundedBorder)
                            
                            TextField("Hover Text", text: $settings.smallImageText)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                }
                
                Divider()
                
                // Buttons
                VStack(alignment: .leading, spacing: 12) {
                    Text("Buttons (max 2)")
                        .font(.headline)
                    
                    // Button 1
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Label")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("Button 1", text: $settings.button1Label)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("URL")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("https://...", text: $settings.button1URL)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                    
                    // Button 2
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Label")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("Button 2", text: $settings.button2Label)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("URL")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("https://...", text: $settings.button2URL)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                }
                
                Divider()
                
                // Party Size
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Party Size")
                            .font(.headline)
                        
                        HStack(spacing: 12) {
                            TextField("Current", value: $settings.partySize, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 80)
                            
                            Text("of")
                            
                            TextField("Max", value: $settings.partyMax, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 80)
                        }
                    }
                    
                    Spacer()
                    
                    // Timestamps
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Timestamps")
                            .font(.headline)
                        
                        Picker("Mode", selection: $settings.timestampMode) {
                            ForEach(TimestampMode.allCases, id: \.self) { mode in
                                Text(mode.displayName).tag(mode)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 200)
                        
                        if settings.timestampMode == .custom {
                            DatePicker(
                                "Start Time",
                                selection: Binding(
                                    get: { settings.customTimestamp ?? Date() },
                                    set: { settings.customTimestamp = $0 }
                                ),
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .datePickerStyle(.compact)
                        }
                    }
                }
                
                Divider()
                
                // Update Button
                HStack {
                    Spacer()
                    
                    Button(action: updatePresence) {
                        Text("Update Presence")
                            .frame(minWidth: 150)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(settings.clientId.isEmpty)
                    
                    Spacer()
                }
                .padding(.vertical, 8)
            }
            .padding()
        }
    }
    
    private func updatePresence() {
        let presence = settings.buildRichPresence(rpcClient: rpcClient)
        Task {
            await rpcClient.setActivity(presence, activityType: settings.activityType)
        }
    }
}
