import SwiftUI
import UniformTypeIdentifiers

public struct ApplicationTab: View {
    @EnvironmentObject var rpcClient: DiscordRPCClient
    @EnvironmentObject var settings: SettingsManager
    @State private var showingLargeImagePicker = false
    @State private var showingSmallImagePicker = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var startTime = Date()
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Activity Type
                VStack(alignment: .leading, spacing: 8) {
                    Text("Activity Type")
                        .font(.system(size: 13, weight: .medium))
                    
                    Picker("", selection: $settings.activityType) {
                        ForEach(ActivityType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                }
                
                // Application ID & Name (Pair)
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Application ID")
                            .font(.system(size: 13, weight: .medium))
                        TextField("Enter application ID", text: $settings.clientId)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Application Name")
                            .font(.system(size: 13, weight: .medium))
                        TextField("Enter application name", text: $settings.appName)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                
                // Details & Details URL (Pair)
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Details (line 1)")
                            .font(.system(size: 13, weight: .medium))
                        TextField("What you're doing", text: $settings.details)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Details URL")
                            .font(.system(size: 13, weight: .medium))
                        TextField("https://...", text: $settings.detailsURL)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                
                // State & State URL (Pair)
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("State (line 2)")
                            .font(.system(size: 13, weight: .medium))
                        TextField("Additional info", text: $settings.state)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("State URL")
                            .font(.system(size: 13, weight: .medium))
                        TextField("https://...", text: $settings.stateURL)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                
                // Stream Link (Single) - only for Streaming type
                if settings.activityType == .streaming {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Stream Link (Twitch or YouTube)")
                            .font(.system(size: 13, weight: .medium))
                        TextField("https://twitch.tv/... or https://youtube.com/...", text: $settings.streamURL)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                
                // Party Size & Max (Pair) - only for Playing type
                if settings.activityType == .playing {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Party Size")
                                .font(.system(size: 13, weight: .medium))
                            TextField("0", text: Binding(
                                get: { settings.partySize > 0 ? "\(settings.partySize)" : "" },
                                set: { settings.partySize = Int($0) ?? 0 }
                            ))
                            .textFieldStyle(.roundedBorder)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Maximum Party Size")
                                .font(.system(size: 13, weight: .medium))
                            TextField("0", text: Binding(
                                get: { settings.partyMax > 0 ? "\(settings.partyMax)" : "" },
                                set: { settings.partyMax = Int($0) ?? 0 }
                            ))
                            .textFieldStyle(.roundedBorder)
                        }
                    }
                }
                
                Divider()
                
                // Large Image & Tooltip (Pair)
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Large Image URL/Key")
                            .font(.system(size: 13, weight: .medium))
                        
                        HStack {
                            Button(action: { showingLargeImagePicker = true }) {
                                HStack {
                                    if let imageData = settings.largeImageData,
                                       let nsImage = NSImage(data: imageData) {
                                        Image(nsImage: nsImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 24, height: 24)
                                            .clipShape(RoundedRectangle(cornerRadius: 4))
                                    } else {
                                        Image(systemName: "photo.badge.plus")
                                            .frame(width: 24, height: 24)
                                    }
                                    Text(settings.largeImageData != nil ? "Change Image" : "Upload Image")
                                }
                            }
                            .buttonStyle(.bordered)
                            .fileImporter(
                                isPresented: $showingLargeImagePicker,
                                allowedContentTypes: [.png, .jpeg, .gif],
                                allowsMultipleSelection: false
                            ) { result in
                                handleImageSelection(result: result, isLarge: true)
                            }
                            .onDrop(of: [.image], isTargeted: nil) { providers in
                                _ = handleDrop(providers: providers, isLarge: true)
                                return true
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Large Image Text")
                            .font(.system(size: 13, weight: .medium))
                        TextField("Hover text for large image", text: $settings.largeImageText)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                
                // Large Image URL (Single)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Large Image clickable URL")
                        .font(.system(size: 13, weight: .medium))
                    TextField("https://...", text: $settings.largeImageURL)
                        .textFieldStyle(.roundedBorder)
                }
                
                // Small Image & Tooltip (Pair)
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Small Image URL/Key")
                            .font(.system(size: 13, weight: .medium))
                        
                        HStack {
                            Button(action: { showingSmallImagePicker = true }) {
                                HStack {
                                    if let imageData = settings.smallImageData,
                                       let nsImage = NSImage(data: imageData) {
                                        Image(nsImage: nsImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 24, height: 24)
                                            .clipShape(Circle())
                                    } else {
                                        Image(systemName: "photo.badge.plus")
                                            .frame(width: 24, height: 24)
                                    }
                                    Text(settings.smallImageData != nil ? "Change Image" : "Upload Image")
                                }
                            }
                            .buttonStyle(.bordered)
                            .fileImporter(
                                isPresented: $showingSmallImagePicker,
                                allowedContentTypes: [.png, .jpeg, .gif],
                                allowsMultipleSelection: false
                            ) { result in
                                handleImageSelection(result: result, isLarge: false)
                            }
                            .onDrop(of: [.image], isTargeted: nil) { providers in
                                _ = handleDrop(providers: providers, isLarge: false)
                                return true
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Small Image Text")
                            .font(.system(size: 13, weight: .medium))
                        TextField("Hover text for small image", text: $settings.smallImageText)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                
                // Small Image URL (Single)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Small Image clickable URL")
                        .font(.system(size: 13, weight: .medium))
                    TextField("https://...", text: $settings.smallImageURL)
                        .textFieldStyle(.roundedBorder)
                }
                
                Divider()
                
                // Button 1 Text & URL (Pair)
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Button1 Text")
                            .font(.system(size: 13, weight: .medium))
                        TextField("Button label", text: $settings.button1Text)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Button1 URL")
                            .font(.system(size: 13, weight: .medium))
                        TextField("https://...", text: $settings.button1URL)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                
                // Button 2 Text & URL (Pair)
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Button2 Text")
                            .font(.system(size: 13, weight: .medium))
                        TextField("Button label", text: $settings.button2Text)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Button2 URL")
                            .font(.system(size: 13, weight: .medium))
                        TextField("https://...", text: $settings.button2URL)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                
                Divider()
                
                // Timestamp Mode
                VStack(alignment: .leading, spacing: 8) {
                    Text("Timestamp Mode")
                        .font(.system(size: 13, weight: .medium))
                    
                    Picker("", selection: $settings.timestampMode) {
                        ForEach(TimestampMode.allCases, id: \.self) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                }
                
                // Custom Timestamps (Pair) - only for custom mode
                if settings.timestampMode == .custom {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Start Timestamp")
                                .font(.system(size: 13, weight: .medium))
                            DatePicker("", selection: Binding(
                                get: { settings.customTimestamp ?? Date() },
                                set: { settings.customTimestamp = $0 }
                            ), displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.compact)
                            .labelsHidden()
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("End Timestamp")
                                .font(.system(size: 13, weight: .medium))
                            DatePicker("", selection: Binding(
                                get: { settings.customEndTimestamp ?? Date() },
                                set: { settings.customEndTimestamp = $0 }
                            ), displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.compact)
                            .labelsHidden()
                        }
                    }
                }
                
                Divider()
                    .padding(.vertical, 8)
                
                // Preview at the bottom
                VStack(spacing: 12) {
                    // Discord Message Card Preview
                    VStack(alignment: .leading, spacing: 0) {
                        // User Header
                        HStack(spacing: 10) {
                            Circle()
                                .fill(Color.blue.opacity(0.3))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.blue)
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text("YourUsername")
                                        .font(.system(size: 13, weight: .semibold))
                                    Text("BOT")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 3)
                                        .padding(.vertical, 1)
                                        .background(Color.blue)
                                        .cornerRadius(3)
                                }
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 10)
                        .padding(.top, 10)
                        .padding(.bottom, 6)
                        
                        // Activity Content
                        HStack(alignment: .top, spacing: 8) {
                            // Large Image with Small Image overlay
                            ZStack(alignment: .bottomTrailing) {
                                if let imageData = settings.largeImageData,
                                   let nsImage = NSImage(data: imageData) {
                                    Image(nsImage: nsImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 60, height: 60)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                } else {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.gray.opacity(0.15))
                                        .frame(width: 60, height: 60)
                                }
                                
                                // Small Image overlay
                                if let imageData = settings.smallImageData,
                                   let nsImage = NSImage(data: imageData) {
                                    Image(nsImage: nsImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 18, height: 18)
                                        .clipShape(Circle())
                                        .offset(x: 4, y: 4)
                                }
                            }
                            
                            // Details
                            VStack(alignment: .leading, spacing: 2) {
                                Text(settings.activityType.displayName)
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.secondary)
                                
                                if !settings.details.isEmpty {
                                    Text(settings.details)
                                        .font(.system(size: 12, weight: .semibold))
                                        .lineLimit(1)
                                }
                                
                                if !settings.state.isEmpty {
                                    Text(settings.state)
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                
                                if settings.partySize > 0 && settings.partyMax > 0 {
                                    Text("\(settings.partySize) of \(settings.partyMax)")
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary)
                                }
                                
                                if settings.timestampMode != .none {
                                    Text(formatElapsedTime(elapsedTime))
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 10)
                        .padding(.bottom, 10)
                    }
                    .frame(maxWidth: 400)
                    .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                }
                .onAppear {
                    startTimer()
                }
                .onDisappear {
                    stopTimer()
                }
            }
            .padding()
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
        return String(format: "%02d:%02d:%02d elapsed", hours, minutes, seconds)
    }
    
    private func handleImageSelection(result: Result<[URL], Error>, isLarge: Bool) {
        do {
            let urls = try result.get()
            guard let url = urls.first else { return }
            
            // Check if we have access to the file
            guard url.startAccessingSecurityScopedResource() else {
                print("Failed to access file")
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }
            
            // Read the image data
            let imageData = try Data(contentsOf: url)
            
            // Store in settings
            if isLarge {
                settings.largeImageData = imageData
            } else {
                settings.smallImageData = imageData
            }
            
            // Upload image and update presence
            uploadImageAndUpdate(data: imageData, isLarge: isLarge)
        } catch {
            print("Error loading image: \(error)")
        }
    }
    
    private func handleDrop(providers: [NSItemProvider], isLarge: Bool) -> Bool {
        guard let provider = providers.first else { return false }
        
        provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async {
                if isLarge {
                    settings.largeImageData = data
                } else {
                    settings.smallImageData = data
                }
                uploadImageAndUpdate(data: data, isLarge: isLarge)
            }
        }
        
        return true
    }
    
    private func uploadImageAndUpdate(data: Data, isLarge: Bool) {
        // TODO: Upload image to Discord CDN or image hosting service
        // For now, just store locally
        print("Image uploaded: \(isLarge ? "large" : "small"), size: \(data.count) bytes")
    }
}

struct ApplicationTab_Previews: PreviewProvider {
    static var previews: some View {
        ApplicationTab()
            .environmentObject(DiscordRPCClient())
            .environmentObject(SettingsManager.shared)
            .frame(width: 600, height: 800)
    }
}
