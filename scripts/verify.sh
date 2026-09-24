#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
project="$repo_root/apps/mobile/RoutineApp.xcodeproj"
scheme="${IOS_SCHEME:-RoutineApp}"
derived_data="${IOS_DERIVED_DATA:-$repo_root/.build/verify}"
full_ui_tests="${IOS_FULL_UI_TESTS:-0}"

for script in "$repo_root"/scripts/*.sh; do
  bash -n "$script"
done

command -v xcodebuild >/dev/null || { echo "xcodebuild is required" >&2; exit 1; }
command -v xcrun >/dev/null || { echo "xcrun is required" >&2; exit 1; }

simulator_id="${IOS_SIMULATOR_ID:-}"
if [[ -z "$simulator_id" ]]; then
  simulator_id="$(xcrun simctl list devices available | awk -F '[()]' '
    /iPhone/ {
      for (field = 2; field <= NF; field++) {
        if ($field ~ /^[[:xdigit:]-]{20,}$/) {
          print $field
          exit
        }
      }
    }')"
fi

[[ -n "$simulator_id" ]] || {
  echo "No available iPhone simulator found." >&2
  xcrun simctl list devices available
  exit 1
}

xcrun simctl boot "$simulator_id" 2>/dev/null || true
xcrun simctl bootstatus "$simulator_id" -b

common_args=(
  -project "$project"
  -scheme "$scheme"
  -destination "platform=iOS Simulator,id=$simulator_id"
  -derivedDataPath "$derived_data"
  CODE_SIGNING_ALLOWED=NO
)

# Compile the app, unit tests, and UI test bundle on every verification run.
xcodebuild "${common_args[@]}" build-for-testing

if [[ "$full_ui_tests" == "1" ]]; then
  xcodebuild "${common_args[@]}" test-without-building
else
  xcodebuild "${common_args[@]}" test-without-building -only-testing:RoutineAppTests
fi
