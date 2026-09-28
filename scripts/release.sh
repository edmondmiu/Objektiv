#!/bin/bash
# Build a Developer ID signed, notarised and stapled Objektiv.zip.
#
#   scripts/release.sh "Developer ID Application: Name (TEAMID)" [notarytool-keychain-profile]
#
# Without a notary profile the zip is signed but not notarised.
set -euo pipefail

IDENTITY="${1:?usage: scripts/release.sh \"Developer ID Application: Name (TEAMID)\" [notary-profile]}"
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

# Re-sign the ad-hoc build with the Developer ID, hardened runtime and a secure timestamp.
ditto build/Build/Products/Release/Objektiv.app "$APP"
codesign --force --options runtime --timestamp --sign "$IDENTITY" "$APP"
codesign --verify --strict --deep --verbose=2 "$APP"
ditto -c -k --keepParent "$APP" "$ZIP"

if [ -n "$PROFILE" ]; then
  xcrun notarytool submit "$ZIP" --keychain-profile "$PROFILE" --wait
  xcrun stapler staple "$APP"
  rm "$ZIP" && ditto -c -k --keepParent "$APP" "$ZIP"
  spctl --assess --type execute --verbose "$APP"
fi

shasum -a 256 "$ZIP"
echo "Release zip: $ZIP"
