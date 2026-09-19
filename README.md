# Routine iOS Starter

A production-oriented SwiftUI starter for consumer habit, productivity, and subscription apps.

## Included

- SwiftUI + Observation
- iOS 18 deployment target
- onboarding + quiz flow
- authentication UI
- subscription/paywall flow
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

The bootstrap script writes `Config/Local.xcconfig`, which is intentionally ignored by Git. The internal Xcode target remains `RoutineApp`; only the user-facing identity and bundle identifiers need to change for most starter use cases.

## Verify

```bash
./scripts/verify.sh
```

The same verification entry point is used by CI. It compiles the app plus unit/UI test targets and runs the unit suite. Run the complete UI suite locally with `IOS_FULL_UI_TESTS=1 ./scripts/verify.sh`.

See [customization](docs/customization.md), [architecture](docs/architecture.md), and the [shipping checklist](docs/shipping-checklist.md).

## Philosophy

This starter favors native Apple frameworks and small protocols over a large dependency graph. External authentication, analytics, persistence, or purchase providers can be swapped behind service seams without rewriting the UI.

## License

MIT. See [LICENSE](LICENSE).
