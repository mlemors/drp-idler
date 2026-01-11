# Setup Guide - Discord RPC Idler

## Quick Start

### 1. GitHub Push (Authentication erforderlich)

Der Code ist committed aber konnte nicht gepusht werden. Du musst dich authentifizieren:

**Option A: SSH (Empfohlen)**
```bash
cd /Users/mlemors/vcs/drp-idler
git remote set-url origin git@github.com:mlemors/drp-idler.git
git push -u origin main
```

**Option B: Personal Access Token**
1. Gehe zu GitHub Settings → Developer settings → Personal access tokens
2. Erstelle neuen Token mit `repo` Zugriff
3. Verwende Token als Passwort beim Push

### 2. Build und Run

```bash
cd /Users/mlemors/vcs/drp-idler
swift build
swift run
```

Die App startet als Menu Bar Icon (oben rechts, Gamecontroller Symbol).

### 3. Discord Application erstellen

1. Gehe zu https://discord.com/developers/applications
2. Klicke "New Application"
3. Gib einen Namen ein (z.B. "My Custom Status")
4. Kopiere die "Application ID"
5. Optional: Lade Assets hoch unter "Rich Presence" → "Art Assets"

### 4. App konfigurieren

1. Klicke auf das Menu Bar Icon
2. Wähle "Settings"
3. Im "Application" Tab:
   - Paste deine Client ID
   - Fülle Details, State, etc. aus
   - Falls du Assets hochgeladen hast, trage die Keys ein
4. Klicke "Update Presence"
5. Öffne Discord - dein Custom Status sollte sichtbar sein!

## Entwicklung mit Xcode (Optional)

Für besseres Development Experience mit Xcode:

```bash
cd /Users/mlemors/vcs/drp-idler
swift package generate-xcodeproj
open DiscordRPCIdler.xcodeproj
```

In Xcode:
- Setze Scheme auf "DiscordRPCIdler"
- Wähle "My Mac" als Destination
- Run (⌘R)

## Projektstruktur

```
drp-idler/
├── Sources/
│   ├── App/
│   │   ├── DiscordRPCIdlerApp.swift  # SwiftUI App Entry Point
│   │   └── AppDelegate.swift          # Menu Bar Setup
│   ├── RPC/
│   │   ├── DiscordRPCClient.swift    # Discord RPC Engine
│   │   └── RPCModels.swift            # Data Models
│   ├── Models/
│   │   └── SettingsManager.swift     # Settings Persistence
│   └── UI/
│       ├── SettingsView.swift        # Main Settings Window
│       ├── ApplicationTab.swift       # RPC Configuration
│       ├── PreviewTab.swift          # Live Preview
│       ├── MenuBarTab.swift          # Launch Settings
│       └── UpdatesTab.swift          # Update Settings
├── Resources/
│   ├── Info.plist                     # App Configuration
│   └── Entitlements.plist            # Permissions
├── Package.swift                      # Swift Package Manager
├── README.md
├── ROADMAP.md                        # Development Roadmap
└── LICENSE
```

## Dependencies

Alle Dependencies werden automatisch via Swift Package Manager heruntergeladen:

- **Sparkle 2.8.1** - Auto-updater framework
- **Defaults 7.3.1** - UserDefaults wrapper
- **LaunchAtLogin 1.1.0** - Launch at login support

## Debugging

### App läuft nicht
```bash
# Check if build successful
swift build

# Check if Discord is running
ps aux | grep Discord

# Check if pipes exist
ls -la /tmp/discord-ipc-*
```

### RPC funktioniert nicht
- Stelle sicher Discord läuft
- Client ID muss korrekt sein (aus Developer Portal)
- Mindestens Details ODER State muss ausgefüllt sein
- Assets müssen in Discord Developer Portal hochgeladen sein

### Console Logs anzeigen
```bash
# While app is running
log stream --predicate 'process == "DiscordRPCIdler"' --level debug
```

## Nächste Schritte

Siehe [ROADMAP.md](ROADMAP.md) für:
- Geplante Features (Profile System, Timeline Scheduler)
- Known Issues
- Testing Checkliste
- Code Signing & Distribution

## Troubleshooting

**"App kann nicht geöffnet werden" (Gatekeeper)**
```bash
xattr -cr /path/to/DiscordRPCIdler.app
```

**"Developer cannot be verified"**
- Rechtsklick → Öffnen → Trotzdem öffnen
- Oder: System Settings → Privacy & Security → Trotzdem erlauben

**Swift Package Manager langsam**
```bash
swift package purge-cache
rm -rf .build
swift build
```

## Support

Bei Fragen oder Problemen:
- GitHub Issues: https://github.com/mlemors/drp-idler/issues
- Discord Developer Docs: https://discord.com/developers/docs

## Credits

Inspired by [Discord-CustomRP](https://github.com/maximmax42/Discord-CustomRP) by maximmax42
