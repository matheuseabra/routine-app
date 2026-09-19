# Customization

## App identity

Run:

```bash
./scripts/bootstrap.sh --name "Focus" --bundle-id com.example.focus --team-id ABC123XYZ --revenuecat-key appl_your_public_sdk_key
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

Authentication, analytics, notifications, and backend sync remain replaceable adapters.

## Before shipping

Replace example Terms, Privacy, and Support URLs, configure RevenueCat products/Offering/entitlement, and upload the App Store In-App Purchase Key in RevenueCat for SDK v5 purchases.
