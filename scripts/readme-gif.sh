#!/bin/zsh
# Renders docs/images/effect.gif (the effect on screen) and docs/images/laptop.gif (a closing laptop showing it),
# and docs/images/laptop-{silk,dusk,mist}.gif (one animation per style), all drawn by the app's Metal renderer.
set -euo pipefail
duobutterfly_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$duobutterfly_root"
command -v xcodegen >/dev/null || { echo 'Install XcodeGen: brew install xcodegen' >&2; exit 2; }
mkdir -p docs/images
duobutterfly_log="$(mktemp "${TMPDIR:-/private/tmp}/DuoButterflyGIF.XXXXXX")"
xcodegen generate >/dev/null
# Purple desktop picture for the laptop animations (the app's own preview image stays unchanged).
duobutterfly_wallpaper="$(mktemp -d "${TMPDIR:-/private/tmp}/DuoButterflyWallpaper.XXXXXX")/wallpaper.png"
swift scripts/draw-preview-desktop.swift "$duobutterfly_wallpaper" 42 dusk >/dev/null
TEST_RUNNER_DUOBUTTERFLY_GIF_WALLPAPER="$duobutterfly_wallpaper" \
  TEST_RUNNER_DUOBUTTERFLY_GIF="$duobutterfly_root/docs/images/effect.gif" \
  TEST_RUNNER_DUOBUTTERFLY_LAPTOP_GIF="$duobutterfly_root/docs/images/laptop.gif" \
  TEST_RUNNER_DUOBUTTERFLY_STYLE_GIF_DIR="$duobutterfly_root/docs/images" xcodebuild -project DuoButterfly.xcodeproj \
  -scheme DuoButterfly -configuration Release -destination 'platform=macOS,arch=arm64' -derivedDataPath .build/DerivedData \
  CODE_SIGNING_ALLOWED=NO ENABLE_TESTABILITY=YES -only-testing:DuoButterflyTests/ReadmeGIFTests test \
  > "$duobutterfly_log" 2>&1 || { echo "Rendering failed, see $duobutterfly_log" >&2; exit 1; }
grep '^GIF:' "$duobutterfly_log" || true
