#!/bin/zsh
set -euo pipefail
duobutterfly_root="$(cd "$(dirname "$0")" && pwd)"
duobutterfly_mode="${1:-check}"
case "$duobutterfly_mode" in
  check|adhoc|development) ;;
  *) echo 'Usage: ./build.sh [check|adhoc|development]' >&2; exit 2 ;;
esac
if [[ "$duobutterfly_mode" == development ]]; then
  : "${DUOBUTTERFLY_SIGN_IDENTITY:?Set DUOBUTTERFLY_SIGN_IDENTITY to a signing certificate name or SHA-1}"
fi
command -v xcodegen >/dev/null || { echo 'Install XcodeGen: brew install xcodegen' >&2; exit 2; }
cd "$duobutterfly_root"
xcodegen generate
duobutterfly_derived="${DUOBUTTERFLY_DERIVED_DATA:-$duobutterfly_root/.build/DerivedData}"
xcodebuild -project DuoButterfly.xcodeproj -scheme DuoButterfly -configuration Release \
  -destination 'platform=macOS,arch=arm64' -derivedDataPath "$duobutterfly_derived" \
  CODE_SIGNING_ALLOWED=NO build
duobutterfly_built="$duobutterfly_derived/Build/Products/Release/DuoButterfly.app"
if [[ "$duobutterfly_mode" == check ]]; then
  echo "Unsigned build for verification: $duobutterfly_built"
  exit 0
fi
duobutterfly_stage="$(mktemp -d "${TMPDIR:-/private/tmp}/DuoButterflyPackage.XXXXXX")"
duobutterfly_app="$duobutterfly_stage/DUO Butterfly.app"
ditto --noextattr --norsrc "$duobutterfly_built" "$duobutterfly_app"
if [[ "$duobutterfly_mode" == adhoc ]]; then
  codesign --force --options runtime --timestamp=none --sign - "$duobutterfly_app"
  duobutterfly_suffix='macos-arm64-adhoc'
else
  codesign --force --options runtime --timestamp=none --sign "$DUOBUTTERFLY_SIGN_IDENTITY" "$duobutterfly_app"
  duobutterfly_suffix='macos-arm64-local'
fi
codesign --verify --deep --strict -R '=identifier "local.duobutterfly.DuoButterfly"' "$duobutterfly_app"
duobutterfly_version=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$duobutterfly_app/Contents/Info.plist")
mkdir -p "$duobutterfly_root/dist"
duobutterfly_output="$duobutterfly_root/dist/DuoButterfly-v${duobutterfly_version}-${duobutterfly_suffix}.zip"
[[ ! -e "$duobutterfly_output" ]] || { echo "Archive already exists: $duobutterfly_output" >&2; exit 2; }
ditto -c -k --norsrc --noextattr --keepParent "$duobutterfly_app" "$duobutterfly_output"
(cd "${duobutterfly_output:h}" && shasum -a 256 "${duobutterfly_output:t}" > "${duobutterfly_output:t}.sha256")
echo "Created: $duobutterfly_output"
