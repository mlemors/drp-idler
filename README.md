# DiscordRPC-Idler

A native macOS menu bar application for managing Discord Rich Presence (RPC).

## Features

- 🎮 Custom Discord Rich Presence configuration
- � Auto-start activity on launch
- 📱 Clean menu bar interface with activity toggle
- 🔌 Automatic reconnection to Discord
- 🌙 Dark mode support
- ⚡️ Automatic updates via Sparkle
- 🚀 Launch at login support
- 🖼️ Automatic app icon loading from Discord API

## Setup

1. Create a Discord Application at https://discord.com/developers/applications
2. Copy your Application ID
3. Launch DiscordRPC-Idler
4. Open Settings from the menu bar icon
5. Paste your Client ID in the Application tab
6. Configure your presence (Details, State, Activity Type, etc.)
7. Your status will automatically update in Discord!

## Usage

- **Toggle Activity**: Click the menu bar icon → Enabled/Disabled
- **Configure**: Click menu bar icon → Settings
- **Activity Types**: Playing, Streaming, Listening, Watching, Competing
- **Party Size**: Optional player count display
- **Launch at Login**: Enable in Settings tab

## Requirements

- macOS 13.0 or later
- Discord application running

## Building from Source

```bash
# Clone the repository
git clone https://github.com/mlemors/discordrpc-idler.git
cd discordrpc-idler

# Build debug version
swift build

# Build release version
swift build -c release

# Run directly
swift run
```

## Creating a Release Build

```bash
# Build release
swift build -c release

# Create app bundle (requires script - see releases)
# Or download pre-built .app from GitHub Releases
```

## License

MIT License - see LICENSE file for details

## Credits

Built with Swift and SwiftUI using:
- [Sparkle](https://sparkle-project.org/) for automatic updates
- [Defaults](https://github.com/sindresorhus/Defaults) for settings persistence
- [LaunchAtLogin](https://github.com/sindresorhus/LaunchAtLogin-Modern) for launch at login support
