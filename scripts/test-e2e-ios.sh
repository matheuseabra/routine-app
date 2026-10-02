#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mobile_root="$repo_root/apps/mobile"
derived_data="$repo_root/.build/e2e-ios"

for tool in xcodebuild xcrun node bun python3; do
  command -v "$tool" >/dev/null || { echo "$tool is required." >&2; exit 1; }
done
node -e 'const [major, minor] = process.versions.node.split(".").map(Number); if (major < 22 || (major === 22 && minor < 12)) { console.error("e2e requires Node.js >=22.12.0"); process.exit(1); }'
[[ -x "$mobile_root/node_modules/.bin/e2e" ]] || {
  echo "Run bun install --frozen-lockfile from the repository root first." >&2
  exit 1
}

# Never attach to an existing simulator: tests get a new device every run.
runtime="${IOS_E2E_RUNTIME:-}"
if [[ -z "$runtime" ]]; then
  runtime="$(xcrun simctl list runtimes -j | python3 -c '
import json, sys
runtimes = [r for r in json.load(sys.stdin)["runtimes"] if r["isAvailable"] and ".iOS-" in r["identifier"] and int(r["version"].split(".")[0]) >= 18]
if not runtimes:
    sys.exit("Install an iOS 18 or newer Simulator runtime in Xcode Settings > Components.")
print(min(runtimes, key=lambda r: tuple(map(int, r["version"].split("."))))["identifier"])
')"
fi
simulator_id="$(xcrun simctl create "Routine Starter E2E" "${IOS_E2E_DEVICE_TYPE:-com.apple.CoreSimulator.SimDeviceType.iPhone-16}" "$runtime")"
cleanup() {
  xcrun simctl shutdown "$simulator_id" >/dev/null 2>&1 || true
  xcrun simctl delete "$simulator_id" >/dev/null 2>&1 || true
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
xcrun simctl boot "$simulator_id"
xcrun simctl bootstatus "$simulator_id" -b

# Override local identity and provider configuration for this isolated build.
xcodebuild -quiet \
  -project "$mobile_root/RoutineApp.xcodeproj" \
  -scheme RoutineApp \
  -configuration Debug \
  -destination "platform=iOS Simulator,id=$simulator_id" \
  -derivedDataPath "$derived_data" \
  CODE_SIGNING_ALLOWED=NO \
  APP_BUNDLE_ID=com.example.routine.starter.e2e \
  AUTH_ENABLED=NO \
  REVENUECAT_API_KEY= \
  build

app_path="$derived_data/Build/Products/Debug-iphonesimulator/RoutineApp.app"
bundle_id="$(/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' "$app_path/Info.plist")"
[[ "$bundle_id" == com.example.routine.starter.e2e ]] || {
  echo "Refusing to run against unexpected app identity: $bundle_id" >&2
  exit 1
}
export IOS_E2E_SIMULATOR_ID="$simulator_id"
export IOS_E2E_APP_PATH="$app_path"
export IOS_E2E_BUNDLE_ID="$bundle_id"
export E2E_TELEMETRY_DISABLED=1
cd "$mobile_root"
# Use the framework's Node CLI, not Bun's test runner.
node node_modules/.bin/e2e run --config e2e/e2e.config.ts "$@"
