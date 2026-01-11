import SwiftUI
import UniformTypeIdentifiers

struct ApplicationTab: View {
    @EnvironmentObject var rpcClient: DiscordRPCClient
    @EnvironmentObject var settings: SettingsManager
    @State private var showingLargeImagePicker = false
    @State private var showingSmallImagePicker = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var startTime = Date()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Preview Card
                VStack(spacing: 12) {
                    Text("Discord Activity Preview")
                        .font(.headline)
                    
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
                            // Large Image - Clickable
                            ZStack(alignment: .bottomTrailing) {
                                Button(action: { showingLargeImagePicker = true }) {
                                    ZStack {
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
                                                .overlay(
                                                    VStack(spacing: 2) {
                                                        Image(systemName: "photo.badge.plus")
                                                            .font(.system(size: 16))
                                                            .foregroundColor(.gray)
                                                        Text("Click")
                                                            .font(.system(size: 7))
                                                            .foregroundColor(.gray)
                                                    }
                                                )
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                                .help("Click to upload large image")
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
                                
                                // Small Image - Clickable overlay
                                if settings.largeImageData != nil {
                                    Button(action: { showingSmallImagePicker = true }) {
                                        ZStack {
                                            if let imageData = settings.smallImageData,
                                               let nsImage = NSImage(data: imageData) {
                                                Image(nsImage: nsImage)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 18, height: 18)
                                                    .clipShape(Circle())
                                            } else {
                                                Circle()
                                                    .fill(Color.gray.opacity(0.2))
                                                    .frame(width: 18, height: 18)
                                                    .overlay(
                                                        Image(systemName: "plus.circle.fill")
                                                            .font(.system(size: 10))
                                                            .foregroundColor(.gray)
                                                    )
                                            }
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    .help("Click to upload small image")
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
                    .frame(width: 400, height: 160)
                    .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    
                    Text("Updates live as you type")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor).opacity(0.3))
                .cornerRadius(8)
                .onAppear {
                    startTimer()
                }
                .onDisappear {
                    stopTimer()
                }
                
                // Configuration Section
                
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
                
                // Party & Timestamps
                HStack(spacing: 12) {
                    GroupBox {
                        HStack(spacing: 8) {
                            TextField("Size", text: Binding(
                                get: { settings.partySize > 0 ? "\(settings.partySize)" : "" },
                                set: { settings.partySize = Int($0) ?? 0 }
                            ))
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 50)
                            
                            Text("/")
                            
                            TextField("Max", text: Binding(
                                get: { settings.partyMax > 0 ? "\(settings.partyMax)" : "" },
                                set: { settings.partyMax = Int($0) ?? 0 }
                            ))
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 50)
                            
                            if settings.partySize > 0 || settings.partyMax > 0 {
                                Button(action: {
                                    settings.partySize = 0
                                    settings.partyMax = 0
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                                .buttonStyle(.plain)
                                .help("Clear party")
                            }
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
    }
    
    private func updatePresence() {
        let presence = settings.buildRichPresence(rpcClient: rpcClient)
        Task {
            await rpcClient.setActivity(presence, activityType: settings.activityType)
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
        
        // Update presence
        updatePresence()
    }
}

struct ApplicationTab_Previews: PreviewProvider {
    static var previews: some View {
        ApplicationTab()
            .environmentObject(DiscordRPCClient())
            .environmentObject(SettingsManager.shared)
            .frame(width: 600, height: 650)
    }
}
