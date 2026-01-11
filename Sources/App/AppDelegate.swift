import AppKit
import SwiftUI

@MainActor
public class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var settingsWindow: NSWindow?
    private var rpcClient: DiscordRPCClient!
    
    public func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize RPC client
        rpcClient = DiscordRPCClient()
        
        // Load client ID from settings
        let settings = SettingsManager.shared
        
        // Set default client ID if not set (from .env for development)
        if settings.clientId.isEmpty {
            settings.clientId = "1459892380864872583"
        }
        
        rpcClient.updateClientId(settings.clientId)
        
        // Configure as menu bar only app (no dock icon)
        NSApp.setActivationPolicy(.accessory)
        
        // Setup menu bar
        setupMenuBar()
        
        // Start RPC client
        Task {
            await rpcClient.startConnectionLoop()
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
        
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Settings", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "About DiscordRPC-Idler", action: #selector(showAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
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
}
