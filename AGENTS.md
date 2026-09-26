# Repository Guidelines

## Project Structure & Architecture

This Bun workspace contains three apps. `apps/mobile` holds the SwiftUI app, `RoutineApp.xcodeproj`, asset catalog, and `RoutineAppTests`/`RoutineAppUITests`. Organize iOS screens under `RoutineApp/Features`, shared UI under `Components` and `DesignSystem`, and provider boundaries under `Services`. `apps/api/src` contains the Hono API, with colocated `*.test.ts` files and Drizzle migrations in `apps/api/drizzle`. `apps/web/src/pages` contains the Astro site. Root `scripts/` handles iOS bootstrap, running, verification, and release checks; `docs/` explains customization and architecture.

## Build, Test & Development Commands

- `bun install --frozen-lockfile` installs workspace dependencies from `bun.lock`.
- `bun run dev` starts the API and web apps; `bun run dev:mobile` builds and launches the iOS simulator app.
- `bun run build` type-checks/builds the API and builds the Astro site.
- `bun run test:api` runs Bun tests for the API.
- `./scripts/verify.sh` compiles the iOS app and both test targets, then runs Swift unit tests. Set `IOS_FULL_UI_TESTS=1` to run the UI suite too. An available iPhone Simulator and Xcode are required.
- `./scripts/preflight.sh` checks release configuration before shipping.

## Coding Style & Naming

Follow the existing formatting: four-space indentation in Swift and two-space indentation in TypeScript. Use `UpperCamelCase` for Swift types and views, `lowerCamelCase` for functions and properties, and descriptive feature folders such as `Features/Paywall`. Keep provider SDK code in services, not views; keep demo data separate from persisted data. No repository-wide formatter or linter is configured, so match neighboring files and rely on the build and test gates.

## Testing Guidelines

Use Swift Testing (`@Test`, `#expect`) in `RoutineAppTests`; UI flows belong in `RoutineAppUITests`. Name tests for observable behavior, such as `routerAdvancesThroughTheProductFlow`. API tests use `bun:test` and the `*.test.ts` suffix. Add focused tests for changed behavior. CI runs `bun run test:api`, `bun run build`, and `./scripts/verify.sh`.

## Commits, Pull Requests & Configuration

Recent commits use scoped messages such as `feature(api): add Bun auth API workspace` and `fix(funnel): refine paywall layout`. Keep commits focused. In pull requests, summarize the change, record verification and simulator UI checks, and update docs when starter behavior changes. Preserve a fresh clone's credential-free path and mock or no-op defaults for new integrations. Keep local iOS values in ignored `apps/mobile/Config/Local.xcconfig` and API secrets in ignored `apps/api/.env`; never commit credentials or personal signing IDs.
