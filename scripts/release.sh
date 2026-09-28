#!/bin/bash
# Build a release Objektiv.zip.
#
#   scripts/release.sh                                          # ad-hoc signed (default)
#   scripts/release.sh "Developer ID Application: Name (TEAMID)" [notarytool-keychain-profile]
#
# Ad-hoc builds carry no developer identity; users approve them once in
# System Settings > Privacy & Security. With a Developer ID the zip is signed,
# and with a notary profile it is also notarised and stapled.
set -euo pipefail

IDENTITY="${1:--}"
PROFILE="${2:-}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/build/release"
APP="$OUT/Objektiv.app"
ZIP="$OUT/Objektiv.zip"

cd "$ROOT"
rm -rf "$OUT" && mkdir -p "$OUT"

xcodebuild -project Objektiv.xcodeproj -scheme Objektiv -configuration Release \
  -derivedDataPath build ARCHS="arm64 x86_64" ONLY_ACTIVE_ARCH=NO \
  build | grep -E "error:|BUILD (SUCCEEDED|FAILED)"

ditto build/Build/Products/Release/Objektiv.app "$APP"
if [ "$IDENTITY" != "-" ]; then
  # Re-sign with the Developer ID, hardened runtime and a secure timestamp.
  codesign --force --options runtime --timestamp --sign "$IDENTITY" "$APP"
fi
codesign --verify --strict --deep --verbose=2 "$APP"
ditto -c -k --keepParent "$APP" "$ZIP"

if [ -n "$PROFILE" ] && [ "$IDENTITY" != "-" ]; then
  xcrun notarytool submit "$ZIP" --keychain-profile "$PROFILE" --wait
  xcrun stapler staple "$APP"
  rm "$ZIP" && ditto -c -k --keepParent "$APP" "$ZIP"
  spctl --assess --type execute --verbose "$APP"
fi

shasum -a 256 "$ZIP"
echo "Release zip: $ZIP"
