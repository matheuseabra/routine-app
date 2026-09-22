#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
config_file="$repo_root/Config/Local.xcconfig"
app_config="$repo_root/RoutineApp/RoutineApp/App/AppConfig.swift"
errors=0

fail() {
  echo "✗ $1" >&2
  errors=$((errors + 1))
}

read_setting() {
  local key="$1"
  awk -F= -v key="$key" '
    $1 ~ "^[[:space:]]*" key "[[:space:]]*$" {
      value=$2
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
      print value
      exit
    }
  ' "$config_file"
}

if [[ ! -f "$config_file" ]]; then
  echo "Release preflight requires Config/Local.xcconfig." >&2
  echo "Run ./scripts/bootstrap.sh first." >&2
  exit 1
fi

bundle_id="$(read_setting APP_BUNDLE_ID)"
team_id="$(read_setting DEVELOPMENT_TEAM_ID)"
revenuecat_app_store_key="$(read_setting REVENUECAT_APP_STORE_API_KEY)"

[[ -n "$bundle_id" ]] || fail "APP_BUNDLE_ID is missing."
[[ "$bundle_id" != com.example.* ]] || fail "APP_BUNDLE_ID still uses com.example.*."
[[ -n "$team_id" && "$team_id" != "YOUR_TEAM_ID" ]] || fail "DEVELOPMENT_TEAM_ID is not configured."
[[ "$revenuecat_app_store_key" == appl_* && "$revenuecat_app_store_key" != *"your_public"* ]] || fail "REVENUECAT_APP_STORE_API_KEY must be configured with the public Apple SDK key (appl_...)."

if grep -q "https://example.com" "$app_config"; then
  fail "Terms, Privacy, or Support URLs still point to example.com."
fi

if (( errors > 0 )); then
  echo
  echo "Release preflight failed with $errors issue(s)." >&2
  exit 1
fi

echo "✓ Release preflight passed."
