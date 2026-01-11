import SwiftUI
import UniformTypeIdentifiers

public struct ApplicationTab: View {
    @EnvironmentObject var rpcClient: DiscordRPCClient
    @EnvironmentObject var settings: SettingsManager
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var updateTimer: Timer?
    @State private var startTime = Date()
    @State private var showingImagePicker = false
    @State private var lastUpdate = Date()
    
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
                        Button(action: { showingImagePicker = true }) {
                            ZStack(alignment: .bottomTrailing) {
                                if let imageData = settings.largeImageData,
                                   let nsImage = NSImage(data: imageData) {
                                    Image(nsImage: nsImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                } else {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 80, height: 80)
                                        .overlay(
                                            Image(systemName: "photo.badge.plus")
                                                .font(.system(size: 24))
                                                .foregroundColor(.gray)
                                        )
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .fileImporter(
                            isPresented: $showingImagePicker,
                            allowedContentTypes: [.png, .jpeg, .gif],
                            allowsMultipleSelection: false
                        ) { result in
                            handleImageSelection(result: result)
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
                            
                            // Stream URL
                            if !settings.streamURL.isEmpty && settings.activityType == .streaming {
                                HStack(spacing: 4) {
                                    Image(systemName: "play.circle.fill")
                                        .font(.system(size: 11))
                                    Text("Streaming")
                                        .font(.system(size: 13))
                                }
                                .foregroundColor(.purple)
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
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Application Name")
                                .font(.system(size: 13, weight: .medium))
                            TextField("Enter application name", text: $settings.appName)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Image")
                                .font(.system(size: 13, weight: .medium))
                            Button(action: { showingImagePicker = true }) {
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
                                    Text("Select Image")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                        }
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
            scheduleActivityUpdates()
        }
        .onDisappear {
            stopTimer()
            updateTimer?.invalidate()
            updateTimer = nil
        }
        .onDrop(of: [.image], isTargeted: nil) { providers in
            handleDrop(providers: providers)
            return true
        }
    }
    
    private func scheduleActivityUpdates() {
        // Update immediately on appear
        Task { await updateActivity() }
        
        // Then update every 5 seconds
        updateTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            // Only update if settings might have changed
            Task { await updateActivity() }
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
    
    private func updateActivity() async {
        // Ensure we're connected
        if !rpcClient.isConnected {
            await rpcClient.reconnect()
            // Give it a moment to connect
            try? await Task.sleep(nanoseconds: 500_000_000) // 500ms
        }
        
        // Build assets
        var assets: RPCAssets? = nil
        if let imageData = settings.largeImageData {
            // For now, we'll use a placeholder since we can't upload images directly
            // In a real implementation, you'd need to upload the image to Discord's CDN first
            assets = RPCAssets(
                largeImage: "custom_image", // This would be the uploaded image key
                largeText: settings.appName,
                smallImage: nil,
                smallText: nil
            )
        }
        
        // Build timestamps
        var timestamps: RPCTimestamps? = nil
        if elapsedTime > 0 {
            let startTimestamp = Int(startTime.timeIntervalSince1970)
            timestamps = RPCTimestamps(start: startTimestamp, end: nil)
        }
        
        // Build party
        var party: RPCParty? = nil
        if settings.partySize > 0 && settings.partyMax > 0 {
            party = RPCParty(
                id: "party-\(UUID().uuidString)",
                size: [settings.partySize, settings.partyMax]
            )
        }
        
        // Build buttons
        var buttons: [RPCButton]? = nil
        if !settings.button1Text.isEmpty && !settings.button1URL.isEmpty {
            buttons = [RPCButton(label: settings.button1Text, url: settings.button1URL)]
        }
        
        // Create rich presence
        let richPresence = RichPresence(
            details: settings.details.isEmpty ? nil : settings.details,
            state: settings.state.isEmpty ? nil : settings.state,
            timestamps: timestamps,
            assets: assets,
            party: party,
            buttons: buttons
        )
        
        // Send to Discord
        await rpcClient.setActivity(richPresence, activityType: settings.activityType)
        
        print("[App] Activity updated with type: \(settings.activityType.displayName)")
    }
    
    private func handleImageSelection(result: Result<[URL], Error>) {
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
            settings.largeImageData = imageData
            
            print("Image loaded: \(imageData.count) bytes")
        } catch {
            print("Error loading image: \(error)")
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) {
        guard let provider = providers.first else { return }
        
        provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async {
                settings.largeImageData = data
                print("Image dropped: \(data.count) bytes")
            }
        }
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

