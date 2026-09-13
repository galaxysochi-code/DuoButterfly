#!/bin/zsh
# Renders docs/images/effect.gif: the lid-closing effect for every style, drawn by the app's Metal renderer.
set -euo pipefail
duobutterfly_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$duobutterfly_root"
command -v xcodegen >/dev/null || { echo 'Install XcodeGen: brew install xcodegen' >&2; exit 2; }
mkdir -p docs/images
duobutterfly_log="$(mktemp "${TMPDIR:-/private/tmp}/DuoButterflyGIF.XXXXXX")"
xcodegen generate >/dev/null
TEST_RUNNER_DUOBUTTERFLY_GIF="$duobutterfly_root/docs/images/effect.gif" xcodebuild -project DuoButterfly.xcodeproj \
  -scheme DuoButterfly -configuration Release -destination 'platform=macOS,arch=arm64' -derivedDataPath .build/DerivedData \
  CODE_SIGNING_ALLOWED=NO ENABLE_TESTABILITY=YES -only-testing:DuoButterflyTests/ReadmeGIFTests test \
  > "$duobutterfly_log" 2>&1 || { echo "Rendering failed, see $duobutterfly_log" >&2; exit 1; }
grep -m1 '^GIF:' "$duobutterfly_log" || true
