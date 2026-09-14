#!/bin/zsh
# Captures README screenshots of real app windows into docs/images.
# DUOBUTTERFLY_SCREENSHOT_SET=review DUOBUTTERFLY_SCREENSHOT_OUT=<dir> captures every section for an interface review.
# Requires screen-recording permission for the terminal running this script.
set -euo pipefail
duobutterfly_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$duobutterfly_root"
command -v xcodegen >/dev/null || { echo 'Install XcodeGen: brew install xcodegen' >&2; exit 2; }
duobutterfly_shots="$(mktemp -d "${TMPDIR:-/private/tmp}/DuoButterflyShots.XXXXXX")"
duobutterfly_out="${DUOBUTTERFLY_SCREENSHOT_OUT:-docs/images}"
mkdir -p "$duobutterfly_out"
xcodegen generate >/dev/null
TEST_RUNNER_DUOBUTTERFLY_SCREENSHOTS="$duobutterfly_shots" \
  TEST_RUNNER_DUOBUTTERFLY_SCREENSHOT_SET="${DUOBUTTERFLY_SCREENSHOT_SET:-readme}" xcodebuild -project DuoButterfly.xcodeproj -scheme DuoButterfly \
  -configuration Release -destination 'platform=macOS,arch=arm64' -derivedDataPath .build/DerivedData \
  CODE_SIGNING_ALLOWED=NO ENABLE_TESTABILITY=YES -only-testing:DuoButterflyTests/ReadmeScreenshotTests test \
  > "$duobutterfly_shots/xcodebuild.log" 2>&1 &
duobutterfly_pid=$!
while kill -0 $duobutterfly_pid 2>/dev/null; do
  for duobutterfly_id in "$duobutterfly_shots"/*.id(N); do
    duobutterfly_name="${duobutterfly_id:t:r}"
    screencapture -x -l "$(<"$duobutterfly_id")" "$duobutterfly_out/$duobutterfly_name.png"
    rm "$duobutterfly_id"
    touch "$duobutterfly_shots/$duobutterfly_name.done"
    echo "Captured $duobutterfly_out/$duobutterfly_name.png"
  done
  sleep 0.3
done
wait $duobutterfly_pid || { echo "Test run failed, see $duobutterfly_shots/xcodebuild.log" >&2; exit 1; }
