#!/bin/sh
#
# Builds CaffeinateBar.app into build/ and runs its self-test.
#
# Usage:
#   Scripts/build.sh                 native architecture
#   Scripts/build.sh --universal     universal binary (arm64 + x86_64)
#   Scripts/build.sh --version 1.2.3 override version (defaults to git describe)
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="CaffeinateBar"
BUILD_DIR="$ROOT/build"
APP="$BUILD_DIR/$APP_NAME.app"

UNIVERSAL=0
VERSION="${VERSION:-$(git -C "$ROOT" describe --tags --always --dirty 2>/dev/null || echo "0.0.0")}"

while [ $# -gt 0 ]; do
    case "$1" in
        --universal) UNIVERSAL=1 ;;
        --version)   VERSION="$2"; shift ;;
        *) echo "Unknown option: $1" >&2; exit 2 ;;
    esac
    shift
done

echo "==> Building $APP_NAME $VERSION ($( [ "$UNIVERSAL" = 1 ] && echo universal || echo native))"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

# --- Compile ---------------------------------------------------------------

BIN="$APP/Contents/MacOS/$APP_NAME"
HOST_ARCH="$(uname -m)"
TARGETS="$HOST_ARCH-apple-macos11.0"
if [ "$UNIVERSAL" = 1 ]; then
    TARGETS="x86_64-apple-macos11.0 arm64-apple-macos11.0"
fi

TMP_BIN="$(mktemp -d)"
first=""
for target in $TARGETS; do
    arch="${target%%-*}"
    out="$TMP_BIN/$APP_NAME-$arch"
    echo "==> swiftc -O ($target)"
    swiftc -O \
        -target "$target" \
        -module-name "$APP_NAME" \
        -o "$out" \
        "$ROOT/Sources/CaffeinateBar/main.swift"
    if [ -z "$first" ]; then
        first="$out"
    else
        lipo -create -output "$BIN" "$first" "$out"
    fi
done
[ -f "$BIN" ] || cp "$first" "$BIN"
rm -rf "$TMP_BIN"

# --- Bundle ----------------------------------------------------------------

echo "==> Writing bundle"
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>$APP_NAME</string>
  <key>CFBundleDisplayName</key><string>$APP_NAME</string>
  <key>CFBundleExecutable</key><string>$APP_NAME</string>
  <key>CFBundleIdentifier</key><string>com.delineas.caffeinate-bar</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>$VERSION</string>
  <key>CFBundleVersion</key><string>$VERSION</string>
  <key>CFBundleDevelopmentRegion</key><string>en</string>
  <key>CFBundleLocalizations</key>
  <array>
    <string>en</string>
    <string>es</string>
  </array>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>LSMinimumSystemVersion</key><string>11.0</string>
  <key>LSUIElement</key><true/>
</dict>
</plist>
PLIST

mkdir -p "$APP/Contents/Resources/en.lproj" "$APP/Contents/Resources/es.lproj"
cp "$ROOT/Resources/en.lproj/Localizable.strings" "$APP/Contents/Resources/en.lproj/"
cp "$ROOT/Resources/es.lproj/Localizable.strings" "$APP/Contents/Resources/es.lproj/"
cp "$ROOT/Resources/AppIcon.icns" "$APP/Contents/Resources/AppIcon.icns"

# --- Sign & verify ----------------------------------------------------------

codesign --force --sign - "$APP"

plutil -lint "$APP/Contents/Info.plist" > /dev/null
test -f "$APP/Contents/Resources/AppIcon.icns"
test -f "$APP/Contents/Resources/en.lproj/Localizable.strings"
test -f "$APP/Contents/Resources/es.lproj/Localizable.strings"

# --- Self-test --------------------------------------------------------------

echo "==> Self-test"
"$BIN" --selftest

echo "==> OK: $APP"
