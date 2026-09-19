# Customization

## App identity

Run:

```bash
./scripts/bootstrap.sh --name "Focus" --bundle-id com.example.focus --team-id ABC123XYZ
```

This creates `Config/Local.xcconfig`. It is ignored by Git so personal signing configuration is not committed.

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
- add the app-specific public Apple SDK key as `REVENUECAT_API_KEY`
- set `REVENUECAT_ENTITLEMENT_ID` (defaults to `pro`)
- configure products, packages, and the current Offering in the RevenueCat dashboard
- the paywall reads RevenueCat Packages and checks entitlement activation after purchase/restore

Authentication is disabled by default. Add `--enable-auth` during bootstrap (or set `AUTH_ENABLED = YES`) only when the auth step is desired. Debug builds use `MockAuthProvider`; Release builds use `UnavailableAuthProvider` until a production provider is injected.

Analytics, notifications, and backend sync remain replaceable adapters.

## Returning-user behavior

Onboarding completion is stored locally. Returning users with an active RevenueCat entitlement go directly to the main app; returning users without one return to the paywall. UI tests can still bypass this behavior with the existing `-screen` launch argument.

## Before shipping

Run `./scripts/preflight.sh`, replace example Terms, Privacy, and Support URLs, configure RevenueCat products/Offering/entitlement, and upload the App Store In-App Purchase Key in RevenueCat for SDK v5 purchases.
