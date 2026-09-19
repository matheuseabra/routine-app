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

Service protocols ship with mock/no-op implementations. Replace only the adapters your app needs: authentication, purchases, analytics, notifications, and backend sync.

## Before shipping

Replace example Terms, Privacy, and Support URLs and configure real StoreKit product identifiers.
