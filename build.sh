#!/bin/bash
# Build script for creating release .app bundle

set -e

echo "🔨 Building DiscordRPC-Idler Release..."

# Clean previous build
rm -rf build/DiscordRPC-Idler.app

# Build release
swift build -c release

# Create app bundle structure
mkdir -p build/DiscordRPC-Idler.app/Contents/{MacOS,Resources,Frameworks}

# Copy binary
cp .build/release/DiscordRPC-Idler build/DiscordRPC-Idler.app/Contents/MacOS/

# Copy frameworks
cp -R .build/release/*.framework build/DiscordRPC-Idler.app/Contents/Frameworks/ 2>/dev/null || true
cp -R .build/release/*.dylib build/DiscordRPC-Idler.app/Contents/Frameworks/ 2>/dev/null || true

# Add rpath
install_name_tool -add_rpath @executable_path/../Frameworks build/DiscordRPC-Idler.app/Contents/MacOS/DiscordRPC-Idler

# Create Info.plist
cat > build/DiscordRPC-Idler.app/Contents/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleExecutable</key>
	<string>DiscordRPC-Idler</string>
	<key>CFBundleIdentifier</key>
	<string>com.mlemors.discordrpc-idler</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>DiscordRPC-Idler</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>LSMinimumSystemVersion</key>
	<string>13.0</string>
	<key>LSUIElement</key>
	<true/>
	<key>NSHumanReadableCopyright</key>
	<string>Copyright © 2026. All rights reserved.</string>
	<key>NSPrincipalClass</key>
	<string>NSApplication</string>
	<key>SUFeedURL</key>
	<string>https://mlemors.github.io/discordrpc-idler/appcast.xml</string>
	<key>SUPublicEDKey</key>
	<string>hyNqw4e6wICfKwmUuDv0xfp7YFCps2qqIVYGO2HsKlk=</string>
</dict>
</plist>
EOF

# Code sign
codesign --force --deep --sign - build/DiscordRPC-Idler.app

echo "✅ Build complete: build/DiscordRPC-Idler.app"
echo ""
echo "To install: cp -R build/DiscordRPC-Idler.app /Applications/"
echo "To create zip: cd build && zip -r DiscordRPC-Idler-v1.0.0.zip DiscordRPC-Idler.app"
