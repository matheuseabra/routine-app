# Architecture

Routine is a Bun workspace monorepo with a small native SwiftUI app, a Hono API shell, and an Astro web shell.

The iOS app and its Xcode project live in `apps/mobile`. The API and web app live in `apps/api` and `apps/web`; `bun run dev` starts both web workspaces, while `bun run dev:mobile` delegates to the existing Xcode simulator script.

## Layers

- **App** owns routing, persisted onboarding state, and application lifecycle.
- **Features** own screen-level UI and feature state.
- **DesignSystem / Components** provide reusable presentation primitives.
- **Models** contain persistent domain models and pure domain calculations.
- **Services** define replaceable boundaries for authentication, purchases, notifications, analytics, and persistence.

## Rules

1. Views should not contain provider-specific SDK code.
2. Production integrations sit behind small protocols.
3. Preview/demo data must be clearly separated from persisted user data.
4. Optional integrations must be safe when unconfigured; mock auth is Debug-only and RevenueCat can show demo pricing without credentials.
5. A clone must run without requiring third-party credentials.
6. `scripts/verify.sh` is the deterministic quality gate for humans and coding agents.

The starter avoids a DI framework, Redux/TCA, or mandatory backend SDK. Add those only when the product requires them.
