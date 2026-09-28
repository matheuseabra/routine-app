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

bun install

./scripts/bootstrap.sh \
  --name "My App" \
  --bundle-id com.example.myapp

./scripts/run-app.sh
```

The bootstrap script writes `apps/mobile/Config/Local.xcconfig`, which is intentionally ignored by Git. A fresh clone runs without third-party credentials. The internal Xcode target remains `RoutineApp`; only the user-facing identity and bundle identifiers need to change for most starter use cases.

## Workspaces

- `apps/mobile` contains the existing SwiftUI app and Xcode project.
- `apps/api` is a minimal Hono API shell with a `/healthz` endpoint.
- `apps/web` is a minimal Astro site shell.

Run the API and web shells together with `bun run dev`, or start one with `bun run dev:api` or `bun run dev:web`. Astro keeps its dev server in the background; stop it with `bun run stop:web`. The iOS app remains independently runnable with `./scripts/run-app.sh` or `bun run dev:mobile`. Build the API and web shells with `bun run build`.

## Optional integrations

### RevenueCat

Enable real subscriptions when you are ready:

```bash
./scripts/bootstrap.sh \
  --name "My App" \
  --bundle-id com.example.myapp \
  --revenuecat-key test_your_test_store_sdk_key \
  --revenuecat-app-store-key appl_your_public_sdk_key \
  --revenuecat-entitlement premium
```

`REVENUECAT_API_KEY` is used by Debug builds, including RevenueCat Test Store `test_` keys. Release builds read `REVENUECAT_APP_STORE_API_KEY`, which must be the public Apple SDK key (`appl_`). The Debug Test Store setting does not flow into the Release app configuration, and Release ignores a `test_` key if one is supplied by mistake. RevenueCat secret `sk_` keys must stay on a server. Without a key for the active build configuration, the starter shows demo pricing but purchase/restore calls remain disabled.

### Authentication

Authentication is off by default. To expose the auth step during development:

```bash
./scripts/bootstrap.sh \
  --name "My App" \
  --bundle-id com.example.myapp \
  --enable-auth
```

Debug builds use the API at `http://localhost:3001` by default. Start it with `bun run dev:api`; the mobile app sends native Sign in with Apple ID tokens to Better Auth and keeps the resulting session cookie in its URL session. Google sign-in remains unavailable until a native Google provider is implemented.

To allow Apple sign-in, configure all Apple values in `apps/api/.env` (the Service ID, Team ID, Key ID, `.p8` private key, and the native app bundle ID), enable Sign in with Apple for that app ID in the Apple Developer portal, and set `AUTH_ENABLED = YES` in `apps/mobile/Config/Local.xcconfig`. Local Apple authorization also requires a valid Apple Developer team and registered bundle ID. Release builds require an HTTPS `ROUTINE_API_BASE_URL` override in `Local.xcconfig`.

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
