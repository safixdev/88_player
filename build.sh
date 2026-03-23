#!/bin/bash
set -e

APP_NAME="Kan88"
APP_DIR="$APP_NAME.app/Contents"

# Build
swift build -c release 2>&1

# Create .app bundle
rm -rf "$APP_NAME.app"
mkdir -p "$APP_DIR/MacOS"
mkdir -p "$APP_DIR/Resources"

cp .build/release/RadioPlayer "$APP_DIR/MacOS/RadioPlayer"
cp Sources/RadioPlayer/Info.plist "$APP_DIR/"
cp Sources/RadioPlayer/AppIcon.icns "$APP_DIR/Resources/"

echo "Built $APP_NAME.app"
echo "Run with: open $APP_NAME.app"
