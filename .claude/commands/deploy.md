Build and deploy 88player (Kan 88 radio) locally.

Steps:
1. Kill any running Kan88 / RadioPlayer process
2. Build the release binary with `swift build -c release`
3. Copy the binary into the app bundle: `sudo cp .build/release/RadioPlayer /Applications/Kan88.app/Contents/MacOS/RadioPlayer`
4. Relaunch with `open /Applications/Kan88.app`
5. Confirm the app is running
