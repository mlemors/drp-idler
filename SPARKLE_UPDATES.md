# Sparkle Auto-Updates Setup

## Der Sparkle Updater ist bereits integriert!

Die App nutzt [Sparkle](https://sparkle-project.org/) für automatische Updates.

### Was bereits gemacht wurde:

✅ Sparkle Framework eingebunden  
✅ EdDSA Schlüsselpaar generiert  
✅ Public Key in Info.plist eingetragen  
✅ Update-Check UI in der App (Updates Tab)

### Um Updates zu veröffentlichen:

1. **GitHub Pages aktivieren** für `gh-pages` Branch
2. **Release erstellen** auf GitHub
3. **Appcast generieren** (siehe unten)

## Schritt-für-Schritt: Ersten Release veröffentlichen

### 1. ZIP für Release erstellen

```bash
cd build
zip -r DiscordRPC-Idler-v1.0.0.zip DiscordRPC-Idler.app
```

### 2. GitHub Release erstellen

1. Gehe zu https://github.com/mlemors/discordrpc-idler/releases
2. "Create a new release"
3. Tag: `v1.0.0`
4. Title: `DiscordRPC-Idler v1.0.0`
5. Lade die ZIP-Datei hoch
6. Publish release

### 3. Appcast generieren

```bash
# Im Projekt-Verzeichnis
/tmp/bin/generate_appcast build/

# Dies erstellt eine appcast.xml Datei
```

### 4. GitHub Pages einrichten

```bash
# Neuen Branch für GitHub Pages erstellen
git checkout --orphan gh-pages
git rm -rf .
echo "# DiscordRPC-Idler Updates" > README.md
cp path/to/appcast.xml .
git add appcast.xml README.md
git commit -m "Add appcast for Sparkle updates"
git push -u origin gh-pages

# Zurück zu main
git checkout main
```

### 5. GitHub Pages aktivieren

1. Gehe zu Repository Settings → Pages
2. Source: Deploy from branch
3. Branch: `gh-pages` / `root`
4. Save

Die App prüft nun automatisch auf Updates unter:  
`https://mlemors.github.io/discordrpc-idler/appcast.xml`

## Private Key Sicherheit

⚠️ **WICHTIG:** Der Private Key ist in deinem macOS Keychain gespeichert unter:
- Name: `Sparkle EdDSA Private Key`
- Account: `com.mlemors.discordrpc-idler`

**Niemals den Private Key committen oder teilen!**

Er wird nur zum Signieren von Updates benötigt. Bewahre ein Backup sicher auf.

## Für zukünftige Updates:

```bash
# 1. Erhöhe Version in build.sh (z.B. 1.0.1)
# 2. Build neue Version
./build.sh

# 3. Erstelle ZIP
cd build && zip -r DiscordRPC-Idler-v1.0.1.zip DiscordRPC-Idler.app

# 4. Signiere und erstelle Appcast
/tmp/bin/generate_appcast build/

# 5. Update appcast.xml in gh-pages Branch
# 6. Erstelle neuen GitHub Release mit ZIP
```

Die App prüft automatisch auf Updates beim Start und zeigt eine Notification wenn ein Update verfügbar ist.
