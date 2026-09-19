# Routine iOS Starter

A production-oriented SwiftUI starter for consumer habit, productivity, and subscription apps.

## Included

- SwiftUI + Observation
- iOS 18 deployment target
- onboarding + quiz flow
- authentication UI
- RevenueCat-backed subscription/paywall flow
- notification permission flow
- task/habit dashboard
- insights and profile screens
- reusable monochrome design system
- unit + UI test targets
- deterministic simulator/device scripts
- GitHub Actions verification

## Quick start

```bash
git clone https://github.com/matheuseabra/routine-app.git
cd routine-app

./scripts/bootstrap.sh \
  --name "My App" \
  --bundle-id com.example.myapp

./scripts/run-app.sh
```

The bootstrap script writes `Config/Local.xcconfig`, which is intentionally ignored by Git. A fresh clone runs without third-party credentials. The internal Xcode target remains `RoutineApp`; only the user-facing identity and bundle identifiers need to change for most starter use cases.

## Optional integrations

### RevenueCat

Enable real subscriptions when you are ready:

```bash
./scripts/bootstrap.sh \
  --name "My App" \
  --bundle-id com.example.myapp \
  --revenuecat-key appl_your_public_sdk_key \
  --revenuecat-entitlement pro
```

Without a RevenueCat key, the starter shows demo pricing but purchase/restore calls remain disabled.

### Authentication

Authentication is off by default. To expose the auth step during development:

```bash
./scripts/bootstrap.sh \
  --name "My App" \
  --bundle-id com.example.myapp \
  --enable-auth
```

Debug builds use the mock auth provider. Release builds intentionally use an unavailable provider until you connect a real implementation.

## Verify

```bash
./scripts/verify.sh
```

The same verification entry point is used by CI. It compiles the app plus unit/UI test targets and runs the unit suite. Run the complete UI suite locally with `IOS_FULL_UI_TESTS=1 ./scripts/verify.sh`.

Before a release, run:

```bash
./scripts/preflight.sh
```

It checks for placeholder bundle IDs, missing signing/RevenueCat configuration, and example legal/support URLs.

See [customization](docs/customization.md), [architecture](docs/architecture.md), and the [shipping checklist](docs/shipping-checklist.md).

## Philosophy

This starter favors native Apple frameworks and small protocols. RevenueCat is the default subscription layer so purchase state, Offerings, Entitlements, restore behavior, and receipt validation stay outside the app. Other external services remain replaceable behind small service seams.

## License

MIT. See [LICENSE](LICENSE).
