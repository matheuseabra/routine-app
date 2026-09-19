#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
project_path="$repo_root/RoutineApp/RoutineApp.xcodeproj"
scheme="${IOS_SCHEME:-RoutineApp}"
configuration="${IOS_CONFIGURATION:-Debug}"
derived_data="${IOS_DERIVED_DATA:-$repo_root/.build/ios}"
bundle_id="${IOS_BUNDLE_ID:-com.matheuseabra.RoutineApp}"
physical=0

usage() {
  cat <<'EOF'
Build and launch Routine on an iPhone Simulator.

Usage:
  ./scripts/run-app.sh [--physical|-p]

Options:
  --physical, -p              Build, install, and launch on a connected iPhone.
  --help, -h                  Show this help.

Simulator overrides:
  IOS_DESTINATION             Full Xcode destination (for example, platform=iOS Simulator,name=iPhone 16).
  IOS_SIMULATOR_ID            Simulator UDID used for boot, install, and launch.
  IOS_SIMULATOR_NAME          Simulator name used when resolving a UDID.

Device override:
  IOS_DEVICE_ID               Physical iPhone UDID. Defaults to the first connected iPhone.

Build overrides:
  IOS_DERIVED_DATA            DerivedData directory (default: ./.build/ios).
  IOS_CONFIGURATION           Build configuration (default: Debug).
  IOS_SCHEME                  Xcode scheme (default: RoutineApp).
  IOS_BUNDLE_ID               Bundle identifier (default: com.matheuseabra.RoutineApp).
  IOS_ALLOW_PROVISIONING_UPDATES=1  Allow Xcode to update signing profiles for a physical build.

Examples:
  ./scripts/run-app.sh
  ./scripts/run-app.sh --physical
  IOS_SIMULATOR_NAME='iPhone 16 (iOS 18)' ./scripts/run-app.sh
  IOS_DEVICE_ID='<iphone-udid>' ./scripts/run-app.sh -p
EOF
}

fail() {
  echo "Error: $*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "Missing required command: $1"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --physical|-p)
      physical=1
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      fail "Unknown argument: $1 (use --help for usage)"
      ;;
  esac
done

[[ -d "$project_path" ]] || fail "Missing Xcode project: $project_path"
require_command xcodebuild
require_command xcrun
mkdir -p "$derived_data"

if [[ "$physical" -eq 1 ]]; then
  device_id="${IOS_DEVICE_ID:-${DEVICE_ID:-}}"
  if [[ -z "$device_id" ]]; then
    device_id="$(xcrun xctrace list devices 2>/dev/null \
      | awk '/^== Simulators ==/{exit} /iPhone .* \([[:xdigit:]-]{20,}\)$/{print}' \
      | sed -E 's/.*\(([[:xdigit:]-]{20,})\)$/\1/' \
      | head -n 1)"
  fi
  [[ -n "$device_id" ]] || fail "No connected iPhone found. Connect an iPhone or set IOS_DEVICE_ID to its UDID."
  xcrun devicectl help >/dev/null 2>&1 || fail "xcrun devicectl is unavailable. Install Xcode 15 or newer to run on a physical iPhone."

  destination="platform=iOS,id=$device_id"
  app_configuration_path="$derived_data/Build/Products/${configuration}-iphoneos/${scheme}.app"
  build_args=(
    -project "$project_path"
    -scheme "$scheme"
    -configuration "$configuration"
    -destination "$destination"
    -derivedDataPath "$derived_data"
    DEVELOPMENT_TEAM="${IOS_TEAM_ID:-F6XDWDLG6B}"
    CODE_SIGN_STYLE=Automatic
  )
  if [[ "${IOS_ALLOW_PROVISIONING_UPDATES:-0}" == "1" ]]; then
    build_args+=(-allowProvisioningUpdates)
  fi

  echo "Building $scheme for physical iPhone $device_id"
  xcodebuild "${build_args[@]}" build
  [[ -d "$app_configuration_path" ]] || fail "Built app not found at $app_configuration_path"
  echo "Installing $bundle_id on $device_id"
  xcrun devicectl device install app --device "$device_id" "$app_configuration_path"
  echo "Launching $bundle_id on $device_id"
  xcrun devicectl device process launch --device "$device_id" "$bundle_id"
  exit 0
fi

destination="${IOS_DESTINATION:-}"
simulator_id="${IOS_SIMULATOR_ID:-}"
simulator_name="${IOS_SIMULATOR_NAME:-}"

if [[ -z "$simulator_id" && "$destination" =~ id=([^,]+) ]]; then
  simulator_id="${BASH_REMATCH[1]}"
fi
if [[ -z "$simulator_name" && "$destination" =~ name=([^,]+) ]]; then
  simulator_name="${BASH_REMATCH[1]}"
fi

if [[ -z "$simulator_id" ]]; then
  simulator_id="$(xcrun simctl list devices available \
    | awk -F '[()]' -v requested_name="$simulator_name" '
      /iPhone/ {
        if (requested_name == "" || index($1, requested_name) > 0) {
          for (field = 2; field <= NF; field++) {
            if ($field ~ /^[[:xdigit:]-]{20,}$/) {
              print $field
              exit
            }
          }
        }
      }')"
fi
[[ -n "$simulator_id" ]] || fail "No available iPhone simulator found. Install an iOS Simulator runtime in Xcode."

if [[ -z "$destination" ]]; then
  destination="platform=iOS Simulator,id=$simulator_id"
fi

echo "Booting simulator $simulator_id"
xcrun simctl boot "$simulator_id" 2>/dev/null || true
xcrun simctl bootstatus "$simulator_id" -b
open -a Simulator >/dev/null 2>&1 || true

app_configuration_path="$derived_data/Build/Products/${configuration}-iphonesimulator/${scheme}.app"
echo "Building $scheme for simulator $simulator_id"
xcodebuild \
  -project "$project_path" \
  -scheme "$scheme" \
  -configuration "$configuration" \
  -destination "$destination" \
  -derivedDataPath "$derived_data" \
  CODE_SIGNING_ALLOWED=NO \
  build

[[ -d "$app_configuration_path" ]] || fail "Built app not found at $app_configuration_path"
echo "Installing $bundle_id on simulator"
xcrun simctl install "$simulator_id" "$app_configuration_path"
echo "Launching $bundle_id on simulator"
xcrun simctl launch "$simulator_id" "$bundle_id"
