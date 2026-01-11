import AppKit
import SwiftUI

@MainActor
public class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var settingsWindow: NSWindow?
    private var rpcClient: DiscordRPCClient!
    
    public func applicationDidFinishLaunching(_ notification: Notification) {
        // Configure as menu bar only app (no dock icon)
        NSApp.setActivationPolicy(.accessory)
        
        // Initialize RPC client
        rpcClient = DiscordRPCClient()
        
        // Load Client ID from settings
        let settings = SettingsManager.shared
        if !settings.clientId.isEmpty {
            rpcClient.updateClientId(settings.clientId)
            print("[App] Loaded Client ID from settings: \(settings.clientId)")
        } else {
            print("[App] No Client ID found in settings")
        }
        
        print("[App] Activity status: \(rpcClient.isActivityEnabled ? "Enabled" : "Disabled")")
        
        // Setup menu bar
        setupMenuBar()
        
        // Start RPC client with delayed connection
        Task {
            // Give Discord and system a moment to be ready
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second initial delay
            
            await rpcClient.startConnectionLoop()
            
            // Wait for connection to establish (longer timeout)
            var attempts = 0
            while !rpcClient.isConnected && attempts < 20 {
                try? await Task.sleep(nanoseconds: 500_000_000) // 500ms
                attempts += 1
            }
            
            print("[App] Connection attempts: \(attempts), Connected: \(rpcClient.isConnected)")
            
            // Send initial activity if connected and enabled
            if rpcClient.isConnected && rpcClient.isActivityEnabled {
                print("[App] Sending initial activity...")
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second for Discord to be ready
                await sendInitialActivity()
                print("[App] Initial activity sent")
            } else {
                print("[App] Skipping initial activity - Connected: \(rpcClient.isConnected), Enabled: \(rpcClient.isActivityEnabled)")
            }
        }
        
        // Setup sleep/wake notifications
        setupSleepWakeNotifications()
    }
    
    public func applicationWillTerminate(_ notification: Notification) {
        Task {
            await rpcClient.disconnect()
        }
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            // Use SF Symbol for now (we'll create custom icon later)
            button.image = NSImage(systemSymbolName: "gamecontroller.fill", accessibilityDescription: "DiscordRPC-Idler")
        }
        
        updateMenu()
    }
    
    private func updateMenu() {
        let menu = NSMenu()
        
        // Activity Toggle
        let activityItem = NSMenuItem(
            title: rpcClient.isActivityEnabled ? "Enabled" : "Disabled",
            action: #selector(toggleActivity),
            keyEquivalent: "a"
        )
        activityItem.state = rpcClient.isActivityEnabled ? .on : .off
        menu.addItem(activityItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Settings", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "About DiscordRPC-Idler", action: #selector(showAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    @objc private func toggleActivity() {
        Task {
            await rpcClient.toggleActivity()
            updateMenu()
        }
    }
    
    @objc private func openSettings() {
        if settingsWindow == nil {
            let settingsView = SettingsView()
                .environmentObject(rpcClient)
            
            let hostingController = NSHostingController(rootView: settingsView)
            
            settingsWindow = NSWindow(contentViewController: hostingController)
            settingsWindow?.title = "DiscordRPC-Idler Settings"
            settingsWindow?.styleMask = [.titled, .closable, .miniaturizable]
            // Don't set initial size here - let SettingsView handle it dynamically
            settingsWindow?.isReleasedWhenClosed = false
            settingsWindow?.center()
            
            // Store window reference in UserDefaults for SettingsView access
            NotificationCenter.default.post(
                name: NSNotification.Name("SettingsWindowCreated"),
                object: settingsWindow
            )
        }
        
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "DiscordRPC-Idler"
        alert.informativeText = "Version 1.0.0\n\nA native macOS menu bar app for Discord Rich Presence.\n\n© 2026"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    private func setupSleepWakeNotifications() {
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(handleWake),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
    }
    
    @objc private func handleWake() {
        // Reconnect after wake
        Task {
            await rpcClient.reconnect()
        }
    }
    
    private func sendInitialActivity() async {
        print("[App] Sending initial activity from AppDelegate...")
        let settings = SettingsManager.shared
        
        // Check if we have any activity data
        guard !settings.details.isEmpty || !settings.state.isEmpty else {
            print("[App] No activity data configured (details and state are empty), skipping initial activity")
            return
        }
        
        print("[App] Activity data - details: '\(settings.details)', state: '\(settings.state)'")
        
        // Build timestamps
        let startTimestamp = Int(Date().timeIntervalSince1970)
        let timestamps = RPCTimestamps(start: startTimestamp, end: nil)
        
        // Build party if set
        var party: RPCParty? = nil
        if settings.partySize > 0 && settings.partyMax > 0 {
            party = RPCParty(
                id: "party-\(UUID().uuidString)",
                size: [settings.partySize, settings.partyMax]
            )
        }
        
        // Build buttons if set
        var buttons: [RPCButton]? = nil
        if !settings.button1Text.isEmpty && !settings.button1URL.isEmpty {
            buttons = [RPCButton(label: settings.button1Text, url: settings.button1URL)]
        }
        
        // Create rich presence
        let richPresence = RichPresence(
            details: settings.details.isEmpty ? nil : settings.details,
            state: settings.state.isEmpty ? nil : settings.state,
            timestamps: timestamps,
            assets: nil,
            party: party,
            buttons: buttons
        )
        
        // Send to Discord
        await rpcClient.setActivity(richPresence, activityType: settings.activityType)
        print("[App] Initial activity sent")
    }
}
