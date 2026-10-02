# Optional iOS end-to-end examples

The starter includes three deterministic [tester-army/e2e](https://github.com/tester-army/e2e) journeys: complete onboarding to the paywall, make a simulated subscription purchase, and create a first task. They use native accessibility queries and explicit assertions. No AI model, subscription, API key, running backend, or RevenueCat configuration is needed.

## Run locally

Requirements: macOS, Xcode with an available iOS Simulator runtime, Bun, Node.js **22.12.0 or newer**, and Python 3. Xcode command-line tools must point to the full Xcode installation.

```bash
bun install --frozen-lockfile
bun run test:e2e:ios
```

The command builds the Debug app, creates and boots a **new disposable iPhone 16 simulator**, runs one worker, and shuts down/deletes that simulator on exit. It uses `.build/e2e-ios` for DerivedData and the fixed test bundle ID `com.example.routine.starter.e2e`, regardless of your ignored Local.xcconfig. Each run has a unique automation session. It never chooses an existing simulator or installs over your normal app. Avoid concurrent runs sharing this DerivedData directory.

By default the runner chooses the oldest available iOS runtime at or above iOS 18. This covers the starter deployment target. To select another installed runtime or device type:

```bash
IOS_E2E_RUNTIME=com.apple.CoreSimulator.SimRuntime.iOS-18-6 \
IOS_E2E_DEVICE_TYPE=com.apple.CoreSimulator.SimDeviceType.iPhone-16 \
bun run test:e2e:ios
```

Pass runner options through the workspace command, for example:

```bash
bun run --filter @routine/mobile test:e2e --grep 'first task'
bun run --filter @routine/mobile typecheck:e2e
```

Reports, JUnit results, screenshots, and retained failure videos are written under `apps/mobile/e2e/.e2e/` and ignored by Git. Telemetry is disabled by the wrapper. A failed run exits nonzero; retries are disabled so failures remain visible.

## Runtime compatibility

The suite was exercised on iPhone 16 / iOS 18.6. On this development machine, agent-device's automation helper stalled before test execution on iOS 26.3; that run was interrupted. If preparation stalls on a newer runtime, select iOS 18.6 with `IOS_E2E_RUNTIME` and check the framework's current compatibility before adopting that newer runtime. The app itself built successfully on both runtimes.

## How the examples work

`e2e/fixtures.ts` installs the built app and launches it before each test. `-e2e` enables Debug-only test behavior: isolated/reset onboarding defaults, an in-memory SwiftData store, and an injected subscription provider with fixed demo plans and successful purchases. RevenueCat initialization is skipped, even if a developer has configured a local key. Release builds ignore this flag and exclude the test subscription provider.

Onboarding starts from a fresh launch and traverses the real screens, choosing “Not now” at the notification step. The other examples use existing `-screen paywall` and `-screen main` shortcuts to keep each journey independent. A new launch resets test data; these examples **do not verify persistence across app restarts**.

The purchase example proves the app's response to a simulated successful entitlement. It does not exercise StoreKit, RevenueCat, billing, restore against a real account, or Apple/Google sign-in. Keep those provider integration checks separate.

## Customize after cloning

- Update `e2e/tests/onboarding.e2e.ts` when changing quiz choices or the funnel. Its copy assertions deliberately describe the starter's default flow.
- Keep accessibility labels meaningful, and prefer stable `.accessibilityIdentifier` values for controls whose copy changes. The examples use identifiers for purchase, plan options, and task saving.
- Extend `E2ESubscriptionProvider` with controlled cancellation/error/restore scenarios when your product needs them.
- Add a separate persistent test store before adding restart/persistence coverage; the current in-memory store intentionally resets each launch.
- Replace the sample task journey with your product's main user action.

## Optional CI and agent actions

This suite is not part of `./scripts/verify.sh` or the default required PR check. To adopt it, add a separate macOS workflow with Node 22.12+, Bun, Xcode, and an installed simulator runtime; run `bun run test:e2e:ios` and upload `apps/mobile/e2e/.e2e/` with `if: always()`. Start with manual runs, then promote it to a PR gate once its runtime and reliability fit your project.

The existing Swift unit tests and XCUITest suite remain available (`IOS_FULL_UI_TESTS=1 ./scripts/verify.sh`).

Agent actions are optional. Follow the framework's [model configuration](https://e2e.tester.army/docs/models) and [security documentation](https://e2e.tester.army/docs/security) before adding a provider and `agent.act(...)`. Keep explicit assertions for outcomes and use synthetic test data. Configuring a remote model can send app observations to that provider and may incur charges; the starter examples do neither.

Dependencies are pinned because the framework is still evolving. When upgrading, run the E2E typecheck and all three journeys against the new versions.
