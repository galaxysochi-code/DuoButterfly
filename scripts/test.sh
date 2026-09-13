#!/bin/zsh
set -euo pipefail
duobutterfly_root="$(cd "$(dirname "$0")/.." && pwd)"
duobutterfly_suite="${1:-unit}"
case "$duobutterfly_suite" in
  unit|all) ;;
  *) echo 'Usage: ./scripts/test.sh [unit|all]' >&2; exit 2 ;;
esac
command -v xcodegen >/dev/null || { echo 'Install XcodeGen: brew install xcodegen' >&2; exit 2; }
cd "$duobutterfly_root"
xcodegen generate
duobutterfly_derived="${DUOBUTTERFLY_DERIVED_DATA:-$duobutterfly_root/.build/DerivedData}"
duobutterfly_results="${DUOBUTTERFLY_TEST_RESULTS:-$(mktemp -d "${TMPDIR:-/private/tmp}/DuoButterflyResults.XXXXXX")/Tests.xcresult}"
duobutterfly_selection=()
if [[ "$duobutterfly_suite" == unit ]]; then
  duobutterfly_selection=(-only-testing:DuoButterflyTests/EffectTests -only-testing:DuoButterflyTests/CursorTests -only-testing:DuoButterflyTests/AppIdentityTests -only-testing:DuoButterflyTests/LocalizationTests -only-testing:DuoButterflyTests/DonationsTests -only-testing:DuoButterflyTests/LidSensorTests)
else
  echo 'All tests require a physical MacBook with an active built-in display; a full-screen animation will appear.'
fi
xcodebuild -project DuoButterfly.xcodeproj -scheme DuoButterfly -configuration Release \
  -destination 'platform=macOS,arch=arm64' -derivedDataPath "$duobutterfly_derived" \
  -resultBundlePath "$duobutterfly_results" CODE_SIGNING_ALLOWED=NO ENABLE_TESTABILITY=YES \
  "${duobutterfly_selection[@]}" test
