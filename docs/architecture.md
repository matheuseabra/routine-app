# Architecture

Routine is deliberately a small native SwiftUI starter.

## Layers

- **App** owns routing and application lifecycle.
- **Features** own screen-level UI and feature state.
- **DesignSystem / Components** provide reusable presentation primitives.
- **Models** contain persistent domain models and pure domain calculations.
- **Services** define replaceable boundaries for authentication, purchases, notifications, analytics, and persistence.

## Rules

1. Views should not contain provider-specific SDK code.
2. Production integrations sit behind small protocols.
3. Preview/demo data must be clearly separated from persisted user data.
4. A clone must run without requiring third-party credentials.
5. `scripts/verify.sh` is the deterministic quality gate for humans and coding agents.

The starter avoids a DI framework, Redux/TCA, or mandatory backend SDK. Add those only when the product requires them.
