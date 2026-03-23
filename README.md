# Kan 88 Player

A lightweight macOS menu bar radio player for Kan 88 (Israeli Public Radio).

## Build

```bash
swift build -c release
```

## Deploy

1. Kill the running app:

```bash
pkill -f Kan88 2>/dev/null
```

2. Copy the binary into the app bundle:

```bash
sudo cp .build/release/RadioPlayer /Applications/Kan88.app/Contents/MacOS/RadioPlayer
```

3. Relaunch:

```bash
open /Applications/Kan88.app
```

Or use the Claude Code command: `/deploy`

## App Bundle

The app lives at `/Applications/Kan88.app` with this structure:

```
Kan88.app/
  Contents/
    Info.plist
    MacOS/
      RadioPlayer    <-- the binary built by swift build
    Resources/
      AppIcon.icns
```

## Features

- Streams Kan 88 live radio
- Play/pause via UI button or keyboard media keys
- Volume control
- Auto-reconnect with exponential backoff
- Now Playing integration (macOS Control Center)
