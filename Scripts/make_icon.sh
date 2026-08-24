#!/bin/sh
# Regenerates Resources/AppIcon.iconset/*.png and Resources/AppIcon.icns
# from Scripts/make_icon.swift. Requires macOS (iconutil).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/Resources/AppIcon.iconset"

swift "$ROOT/Scripts/make_icon.swift" "$OUT"
iconutil -c icns "$OUT" -o "$ROOT/Resources/AppIcon.icns"
echo "==> OK: $OUT and $ROOT/Resources/AppIcon.icns updated"
