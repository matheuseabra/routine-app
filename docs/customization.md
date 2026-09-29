# Customization

## App identity

Run:

```bash
./scripts/bootstrap.sh --name "Focus" --bundle-id com.example.focus --team-id ABC123XYZ
```

This creates `apps/mobile/Config/Local.xcconfig`. It is ignored by Git so personal signing configuration is not committed.

## Brand

The starter keeps the internal `RoutineApp` target and type names stable. Customize:

- `Assets.xcassets/AppIcon.appiconset`
- colors in `Assets.xcassets/Routine*.colorset`
- typography in `DesignSystem/Typography.swift`
- logo components in `Components/RoutineLogo.swift`
- product copy in feature views / configuration

Keeping the internal target stable makes upgrades and template diffs easier.

## Services

Service protocols ship with mock/no-op implementations where appropriate.

Subscriptions use RevenueCat by default:
- set `REVENUECAT_API_KEY` to a Test Store `test_` SDK key for Debug purchase testing
- set `REVENUECAT_APP_STORE_API_KEY` to the public Apple SDK key (`appl_`) for Release builds
- keep RevenueCat secret `sk_` keys on a server; they are not app SDK keys
- set `REVENUECAT_ENTITLEMENT_ID` (defaults to `premium`)
- configure products, packages, and the current Offering in the RevenueCat dashboard
- attach purchased products to the same entitlement ID configured above; the paywall validates that exact entitlement after purchase/restore

Authentication is disabled by default. Add `--enable-auth` during bootstrap (or set `AUTH_ENABLED = YES`) only when the auth step is desired. When enabled, Debug builds use `ROUTINE_API_BASE_URL` (default `http://localhost:3001`) and sign in with Apple through the Hono/Better Auth API. Configure the API's Apple credentials and the iOS Sign in with Apple entitlement before using real accounts. Google sign-in is not implemented yet. Release builds use the configured HTTPS API endpoint or fail as unavailable.

Analytics, notifications, and backend sync remain replaceable adapters.

## Returning-user behavior

Onboarding completion is stored locally. Returning users with an active RevenueCat entitlement go directly to the main app; returning users without one return to the paywall. UI tests can still bypass this behavior with the existing `-screen` launch argument.

## Before shipping

Run `./scripts/preflight.sh`, replace example Terms, Privacy, and Support URLs, configure RevenueCat products/Offering/entitlement, and upload the App Store In-App Purchase Key in RevenueCat for SDK v5 purchases.
