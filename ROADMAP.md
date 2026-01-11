# Discord RPC Idler - Development Roadmap

## ✅ Completed (MVP - Version 1.0)

### Core Features
- [x] Native Swift/SwiftUI macOS menu bar application
- [x] Discord RPC protocol implementation (Unix domain sockets)
- [x] Auto-reconnect to Discord (5-second interval, pipes 0-9)
- [x] Settings persistence with Defaults library
- [x] 4-tab settings UI:
  - Application: Client ID, activity type, details/state, images, buttons, party, timestamps
  - Preview: Live Discord message card mockup
  - Menu Bar: Launch at login
  - Updates: Sparkle auto-updater integration
- [x] Menu bar integration with NSStatusItem
- [x] Launch at login support
- [x] Sleep/wake auto-reconnect handling

### Technical
- [x] Swift Package Manager setup
- [x] Dependencies: Sparkle 2.x, Defaults, LaunchAtLogin-Modern
- [x] Info.plist with LSUIElement (menu bar only)
- [x] Network client entitlements
- [x] Git repository initialized
- [x] MIT License
- [x] README documentation

## 🚀 Next Steps (To be completed)

### 1. GitHub Push
**Status:** Ready, needs authentication
```bash
cd /Users/mlemors/vcs/drp-idler
git push -u origin main
```
**Issue:** Permission denied (403). Du musst entweder:
- SSH-Key zu deinem GitHub Account hinzufügen, oder
- Personal Access Token verwenden, oder
- Remote URL auf SSH umstellen: `git remote set-url origin git@github.com:mlemors/drp-idler.git`

### 2. Custom Menu Bar Icon
**Current:** Temporary SF Symbol (`gamecontroller.fill`)
**Todo:** 
- Design minimalistisches Discord-inspired Icon
- Export als .png (16x16@1x, 32x32@2x, 64x64@3x)
- Als Template Image markieren (monochrom für Dark/Light Mode)
- In AppDelegate laden: `NSImage(named: "MenuBarIcon")`

### 3. RPC Protocol Verbesserungen
**Current:** Grundlegende Handshake/SET_ACTIVITY Implementation
**Todo:**
- Response reading von Discord implementieren (READY event parsing)
- Error handling für falsche Client IDs
- User info aus READY event extrahieren (username, discriminator)
- Pipe detection optimieren (nur existierende Pipes probieren)

### 4. Xcode Project Setup
**Current:** Swift Package Manager (Command line)
**Todo (Optional):**
- Xcode Projekt erstellen für besseres Development Experience
- Build Phases für Info.plist und Entitlements
- Asset Catalog für App Icon
- Code Signing Konfiguration
- Archive für Distribution

### 5. Testing
- [ ] Teste mit verschiedenen Discord Client IDs
- [ ] Teste alle Activity Types (Playing, Listening, Watching, Competing)
- [ ] Teste Timestamps (None, Since Start, Custom)
- [ ] Teste Images (Assets aus Discord Developer Portal)
- [ ] Teste Buttons (URLs validieren)
- [ ] Teste Party Size
- [ ] Teste Launch at Login
- [ ] Teste Sleep/Wake Reconnect
- [ ] Teste mit Discord nicht laufend → starten → automatische Connection

### 6. Sparkle Setup für Updates
**Todo:**
- Generate EdDSA keys: `./generate_keys`
- Update Info.plist mit Public Key
- Setup GitHub Pages für Appcast hosting
- Create appcast.xml
- Test update mechanism

### 7. Code Signing & Notarization
**Todo:**
- Apple Developer Account (notwendig für Distribution)
- Code Signing Certificate erstellen
- App signieren: `codesign --deep --force --sign "Developer ID" DiscordRPCIdler.app`
- Notarisierung bei Apple: `xcrun notarytool submit`
- DMG oder .zip Distribution erstellen

### 8. UI/UX Polishing
- [ ] Loading states für RPC connection
- [ ] Error messages bei fehlerhaften Inputs
- [ ] Tooltips für Image Keys (Erklärung Asset System)
- [ ] Validation für URLs (Buttons)
- [ ] Better Preview (zeige actual Discord theme colors)
- [ ] Keyboard shortcuts (⌘, für Settings)

## 🔮 Future Features (v2.0+)

### Profile System
- Multiple profiles mit Namen
- Profile quick-switch im Menu Bar
- Import/Export profiles (.drp oder .json)
- Active profile indicator

### Timeline/Scheduler
- Time-based profile switching
- Weekday selection
- Recurring schedules
- Conflict detection

### Running Apps Detection
- NSWorkspace integration
- Auto-switch based on running apps
- Bundle ID matching
- Custom app mapping

### Discord Integration
- Fetch available assets from Discord API
- Asset preview in UI
- OAuth flow für user authentication
- Display connected Discord user

### UI Enhancements
- Drag & drop .crp file import
- Multiple windows support
- Better color scheme (Discord theme)
- Animations
- Onboarding flow für erste Verwendung

## 📝 Known Issues

1. **RPC Response Reading:** Aktuell wird keine Antwort von Discord gelesen, nur gesendet
2. **Connection Status:** Keine visuelle Indikation ob Discord gefunden wurde
3. **Error Handling:** Minimales error handling, keine user feedback
4. **Icon:** Temporary SF Symbol statt custom Icon

## 🛠 Development Commands

```bash
# Build
swift build

# Run
swift run

# Clean build
swift package clean

# Update dependencies
swift package update

# Generate Xcode project (optional)
swift package generate-xcodeproj
```

## 📚 Resources

- [Discord RPC Documentation](https://discord.com/developers/docs/topics/rpc)
- [Discord Developer Portal](https://discord.com/developers/applications)
- [Sparkle Documentation](https://sparkle-project.org/documentation/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Discord-CustomRP Reference](https://github.com/maximmax42/Discord-CustomRP)

## 🎯 Current State

Die App ist **funktionsfähig** aber noch nicht production-ready. Der Code kompiliert erfolgreich und die Core-Features sind implementiert. Die nächsten Schritte sind:

1. GitHub Push (nach Auth-Fix)
2. Custom Icon hinzufügen
3. RPC Response-Reading implementieren
4. Extensive Testing
5. Code Signing & Distribution Setup
