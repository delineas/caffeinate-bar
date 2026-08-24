#!/bin/sh
# Compila CaffeinateBar.app. Uso: ./build.sh
set -e
cd "$(dirname "$0")"
APP="CaffeinateBar.app"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
swiftc -O -target x86_64-apple-macosx11.0 CaffeinateBar.swift -o "$APP/Contents/MacOS/CaffeinateBar"

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>CaffeinateBar</string>
  <key>CFBundleExecutable</key><string>CaffeinateBar</string>
  <key>CFBundleIdentifier</key><string>local.caffeinate-bar</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>LSMinimumSystemVersion</key><string>11.0</string>
  <key>LSUIElement</key><true/>
</dict>
</plist>
PLIST

"$APP/Contents/MacOS/CaffeinateBar" --selftest
echo "OK -> $APP  (ábrela con: open $APP)"
