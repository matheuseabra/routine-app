# Production Readiness Roadmap

This roadmap takes Routine from a lean iOS starter into a production-ready product without turning the codebase into a framework-heavy monolith.

The work is intentionally split into small vertical slices. Each milestone should land as its own PR (or a very small sequence of PRs when explicitly noted), must pass its quality gate, and should leave the repository in a releasable state.

## Product architecture principles

Non-negotiables:

- [ ] One monorepo containing the iOS app, API, marketing site, shared TypeScript packages, docs, and scripts.
- [ ] Bun as the JavaScript/TypeScript runtime and package manager.
- [ ] Bun workspaces as the initial monorepo orchestration layer.
- [ ] No Turborepo initially. Add it only when there is measured value from task-graph caching/orchestration.
- [ ] SwiftUI remains the native iOS UI layer.
- [ ] SwiftData remains the local-first on-device persistence layer.
- [ ] RevenueCat remains the subscription/billing abstraction.
- [ ] Hono + Bun + TypeScript for the API.
- [ ] Drizzle ORM + SQLite for the initial backend data layer.
- [ ] Drizzle Studio for local database inspection.
- [ ] Astro + React + TypeScript + Bun + Tailwind CSS + shadcn/ui for the marketing site.
- [ ] PostHog iOS SDK for product analytics.
- [ ] The app must continue to run locally without third-party credentials unless a feature explicitly requires them.
- [ ] CI must have deterministic commands that also run locally.
- [ ] Avoid introducing generic abstractions before a concrete product need exists.

## Target repository shape

```text
routine-app/
├── apps/
│   ├── ios/
│   │   ├── RoutineApp.xcodeproj
│   │   ├── RoutineApp/
│   │   ├── RoutineAppTests/
│   │   ├── RoutineAppUITests/
│   │   └── Config/
│   │
│   ├── api/
│   │   ├── src/
│   │   │   ├── db/
│   │   │   ├── routes/
│   │   │   ├── middleware/
│   │   │   └── index.ts
│   │   ├── drizzle/
│   │   ├── drizzle.config.ts
│   │   ├── package.json
│   │   └── tsconfig.json
│   │
│   └── web/
│       ├── src/
│       │   ├── components/
│       │   ├── layouts/
│       │   ├── pages/
│       │   └── styles/
│       ├── astro.config.mjs
│       ├── package.json
│       └── tsconfig.json
│
├── packages/
│   └── contracts/
│       ├── src/
│       ├── package.json
│       └── tsconfig.json
│
├── docs/
│   ├── ROADMAP.md
│   └── ...
│
├── scripts/
├── package.json
├── bun.lock
└── README.md
```

Notes:

- `apps/ios` lives in the monorepo but is not a Bun workspace.
- Bun workspaces cover `apps/api`, `apps/web`, and `packages/*`.
- `packages/contracts` is for shared TypeScript request/response validation and DTOs used by API/web.
- The iOS client keeps explicit Swift `Codable` models initially. Do not add Swift OpenAPI codegen until API drift becomes a demonstrated maintenance problem.

## Root workspace contract

The root `package.json` should eventually look conceptually like:

```json
{
  "private": true,
  "workspaces": [
    "apps/api",
    "apps/web",
    "packages/*"
  ]
}
```

Expected root commands:

```bash
bun install
bun run dev
bun run check
bun run test
bun run typecheck
bun run build
bun run db:studio
```

Use Bun workspace filtering for package-specific tasks rather than adding a task runner immediately.

### Turborepo adoption gate

Do **not** add Turborepo until at least one of these becomes true:

- [ ] There are 3+ JavaScript workspaces with real build dependencies between them.
- [ ] JavaScript CI remains materially slow after normal dependency caching.
- [ ] Remote build caching would remove meaningful repeated work.
- [ ] Task ordering becomes difficult to express cleanly with Bun workspace filters.

If none of those are true, Bun workspaces remain the simpler choice.

---

# Phase 1 — Monorepo foundation

Goal: reorganize the existing project into the final repository shape without changing product behavior.

## Slice 1.1 — Move iOS into `apps/ios`

- [ ] Move the existing Xcode project and targets under `apps/ios`.
- [ ] Move iOS-specific `Config/` under `apps/ios/Config/`.
- [ ] Update `scripts/run-app.sh`, `scripts/verify.sh`, `scripts/preflight.sh`, CI paths, and docs.
- [ ] Preserve the existing shared Xcode scheme.
- [ ] Preserve Swift Package Manager resolution.
- [ ] Ensure all relative resource/font paths still resolve.
- [ ] Do not change application behavior in this PR.

## Slice 1.2 — Add Bun workspace root

- [ ] Add root `package.json` with `private: true`.
- [ ] Add Bun workspace globs.
- [ ] Commit `bun.lock`.
- [ ] Add empty/minimal `apps/api`, `apps/web`, and `packages/contracts` workspace manifests.
- [ ] Add root commands for `dev`, `check`, `test`, `typecheck`, and `build`.
- [ ] Add `.env.example` conventions for JS workspaces.
- [ ] Document environment variable ownership by app.

## CI changes

- [ ] Keep the existing iOS macOS job.
- [ ] Add a Linux Bun job for install/typecheck/test/build.
- [ ] Use `bun install --frozen-lockfile` in CI.
- [ ] Do not require macOS for API/web checks.

## Quality gate

- [ ] Fresh clone opens and builds the Xcode project.
- [ ] Existing iOS unit tests pass.
- [ ] Existing iOS UI-test target compiles.
- [ ] `bun install --frozen-lockfile` succeeds.
- [ ] Root Bun scripts succeed.
- [ ] No product behavior changed.
- [ ] No Turborepo dependency added.

---

# Phase 2 — Local API + SQLite vertical slice

Goal: create a real local backend that can persist and inspect tasks during development.

## API foundation

- [ ] Build `apps/api` with Hono running on Bun.
- [ ] Add `GET /healthz`.
- [ ] Add structured JSON error responses.
- [ ] Add request IDs.
- [ ] Add environment validation at startup.
- [ ] Add graceful startup/shutdown behavior appropriate for the deployment target.

## Database

- [ ] Add Drizzle ORM.
- [ ] Use `bun:sqlite` locally.
- [ ] Store the development database under an ignored path such as `apps/api/.data/routine.sqlite`.
- [ ] Add `drizzle.config.ts`.
- [ ] Commit generated SQL migrations.
- [ ] Add scripts:
  - [ ] `db:generate`
  - [ ] `db:migrate`
  - [ ] `db:studio`
  - [ ] `db:seed`
  - [ ] `db:reset`
- [ ] Use Drizzle Studio as the default local DB browser.

## First domain slice: tasks

Create a minimal tasks schema with stable UUIDs and sync-friendly timestamps.

Suggested initial fields:

- [ ] `id`
- [ ] `title`
- [ ] `is_completed`
- [ ] `created_at`
- [ ] `updated_at`
- [ ] `deleted_at` (nullable tombstone for future sync)
- [ ] `user_id` nullable until authenticated sync is introduced

Endpoints:

- [ ] `GET /v1/tasks`
- [ ] `POST /v1/tasks`
- [ ] `PATCH /v1/tasks/:id`
- [ ] `DELETE /v1/tasks/:id`

## Contracts

- [ ] Put shared TypeScript request/response schemas in `packages/contracts`.
- [ ] Validate API input at the boundary.
- [ ] Keep API response envelopes stable and versioned.
- [ ] Do not expose Drizzle row types directly as the public API contract.

## Tests

- [ ] Hono route tests use `bun:test`.
- [ ] DB integration tests use a temporary or in-memory SQLite database.
- [ ] Test validation failures.
- [ ] Test duplicate UUID behavior.
- [ ] Test soft-delete/tombstone behavior.

## Quality gate

- [ ] `bun --filter @routine/api test` passes.
- [ ] A new database can be created from migrations only.
- [ ] Applying migrations to an already-current DB is safe.
- [ ] CRUD works from a clean local database.
- [ ] `bun run db:studio` opens the development DB.
- [ ] No production deployment yet; unauthenticated task endpoints must not be publicly exposed.

---

# Phase 3 — Production identity vertical slice

Goal: replace development-only authentication with a real account/session path before cloud data is enabled.

Keep local-only usage possible for users who do not sign in.

## Auth decision gate

Before implementation:

- [ ] Decide whether to use a dedicated auth library/provider or own the small OIDC/session layer.
- [ ] Document why the selected option is appropriate for Bun/Hono/Drizzle.
- [ ] Keep the existing `AuthProviding` seam in iOS.
- [ ] Start with Sign in with Apple.
- [ ] Treat Google sign-in as a separate optional slice.

## API identity model

- [ ] Add `users`.
- [ ] Add `sessions` or equivalent refresh-token/session storage.
- [ ] Associate cloud records with a stable internal user UUID.
- [ ] Add `GET /v1/me`.
- [ ] Protect authenticated routes with Hono middleware.

## iOS

- [ ] Add a real `AuthProviding` implementation.
- [ ] Store refresh/session credentials in Keychain, not UserDefaults.
- [ ] Keep auth disabled when credentials/provider configuration is absent.
- [ ] Identify the user with a stable internal backend user ID after login.
- [ ] Logout invalidates local session state and calls analytics reset later when PostHog lands.

## Security

- [ ] Expired/invalid sessions return 401.
- [ ] Refresh behavior is explicit and tested.
- [ ] Logout revokes the current refresh/session token.
- [ ] Never log raw identity tokens or refresh tokens.
- [ ] No auth secrets in the iOS bundle.

## Quality gate

- [ ] Fresh user can sign in on iOS and receive `/v1/me`.
- [ ] Session survives app relaunch.
- [ ] Logout revokes access.
- [ ] Protected task endpoints reject anonymous callers.
- [ ] Release build cannot silently fall back to mock auth.
- [ ] Local-only users can still use SwiftData without signing in.

---

# Phase 4 — Local-first task sync vertical slice

Goal: connect the existing SwiftData task experience to the API without making the UI network-dependent.

Principle:

> UI writes to SwiftData immediately. Sync happens behind the UI. The app remains useful offline.

## iOS sync implementation

- [ ] Add a small `TaskAPIClient`.
- [ ] Add a focused `TaskSyncService`; do not introduce a generic repository framework.
- [ ] Keep SwiftData as the immediate UI source.
- [ ] Track unsynced local mutations.
- [ ] Push pending mutations after authentication/network recovery.
- [ ] Pull server changes after login/app foreground/explicit refresh.
- [ ] Preserve stable task UUIDs across local/server records.

## Conflict policy v1

Keep the first policy simple and documented:

- [ ] Server timestamps are canonical for remote ordering.
- [ ] Repeated mutation retries are idempotent.
- [ ] Last-write-wins is acceptable for v1 personal task edits.
- [ ] Deletes create tombstones so they propagate across devices.
- [ ] Define tombstone retention before cleanup.

## Network behavior

- [ ] Centralize API base URL configuration.
- [ ] Add request timeout behavior.
- [ ] Retry only safe/idempotent operations automatically.
- [ ] Treat 401 differently from transient network failures.
- [ ] Do not block task creation on network availability.

## Quality gate

- [ ] Create a task offline → reconnect → task appears in API DB.
- [ ] Create a task remotely → refresh app → task appears locally.
- [ ] Completing a task syncs without destroying check-in history.
- [ ] Retrying the same mutation does not create duplicates.
- [ ] Deleting on one client propagates to another.
- [ ] Two-client conflict behavior matches the documented policy.
- [ ] SwiftData-only mode still works when no account exists.

---

# Phase 5 — Sync habits and check-ins

Goal: complete cloud portability of the current core domain without expanding product scope.

## Backend

- [ ] Add `habits` table.
- [ ] Add `check_ins` table.
- [ ] Add migrations.
- [ ] Add versioned Hono routes.
- [ ] Add ownership checks.

## iOS

- [ ] Extend sync to `RoutineHabit`.
- [ ] Extend sync to `RoutineCheckIn`.
- [ ] Keep Insights derived locally from synchronized domain data.
- [ ] Preserve existing SwiftData offline behavior.

## Quality gate

- [ ] Task, habit, and check-in records all survive reinstall/sign-in on another device.
- [ ] User A cannot read or mutate User B records.
- [ ] Local metrics match the synchronized data set.
- [ ] Migrations preserve existing local development records.
- [ ] Full domain sync integration tests pass.

---

# Phase 6 — Marketing website vertical slice

Goal: ship the public one-page product site as a static-first Astro application.

## Stack

- [ ] Astro.
- [ ] TypeScript.
- [ ] Bun.
- [ ] React integration only for interactive islands.
- [ ] Tailwind CSS 4 through the supported Vite integration.
- [ ] shadcn/ui for the small set of interactive UI primitives that actually need it.

## Architecture rule

Prefer:

```text
Astro static HTML
    ↓
React island only when interaction requires it
```

Avoid turning the landing page into a React SPA.

## One-page content

- [ ] Hero.
- [ ] Product screenshots/device frames.
- [ ] Core value proposition.
- [ ] How it works.
- [ ] Feature blocks.
- [ ] Habit/task/insights/paywall product preview.
- [ ] FAQ.
- [ ] App Store/TestFlight CTA configured via environment variable.
- [ ] Footer.
- [ ] Terms route.
- [ ] Privacy route.
- [ ] Support route.

Do not publish unsupported productivity claims or fake social proof.

## SEO / delivery

- [ ] Canonical URL.
- [ ] OpenGraph metadata.
- [ ] Twitter/X metadata.
- [ ] Sitemap.
- [ ] robots.txt.
- [ ] favicon/app icon assets.
- [ ] Responsive mobile layout.
- [ ] Static output by default.
- [ ] Deployment target selected and documented.

## Quality gate

- [ ] `astro check` passes.
- [ ] Production build passes.
- [ ] No unnecessary React hydration for static sections.
- [ ] Mobile Lighthouse targets:
  - [ ] Performance >= 90
  - [ ] Accessibility >= 95
  - [ ] Best Practices >= 95
  - [ ] SEO >= 95
- [ ] Terms/Privacy/Support URLs can replace the iOS `example.com` placeholders.
- [ ] CTA URL is environment-configurable.

---

# Phase 7 — PostHog product analytics vertical slice

Goal: instrument the actual product funnel without leaking user content.

## iOS SDK

- [ ] Add the official PostHog iOS SDK through Swift Package Manager.
- [ ] Add `POSTHOG_PROJECT_TOKEN` and `POSTHOG_HOST` to local xcconfig conventions.
- [ ] Initialize PostHog once near app startup when configured.
- [ ] Implement `PostHogAnalyticsTracker` behind the existing `AnalyticsTracking` protocol.
- [ ] Keep `NoopAnalyticsTracker` when PostHog is unconfigured.

## Event taxonomy

Use explicit typed events rather than arbitrary strings throughout feature views.

Initial funnel:

- [ ] `onboarding_started`
- [ ] `onboarding_completed`
- [ ] `quiz_completed`
- [ ] `plan_viewed`
- [ ] `auth_succeeded`
- [ ] `paywall_viewed`
- [ ] `trial_started`
- [ ] `purchase_completed`
- [ ] `purchase_restored`
- [ ] `task_created`
- [ ] `task_completed`
- [ ] `habit_created`
- [ ] `reminder_permission_result`

## Privacy rules

Never send these as analytics properties:

- [ ] task titles
- [ ] habit titles
- [ ] free-form user-entered text
- [ ] quiz name input
- [ ] auth tokens
- [ ] RevenueCat keys
- [ ] raw email unless there is a deliberate documented need

After authentication:

- [ ] identify using the stable backend user UUID.
- [ ] keep email/name as optional person properties only if privacy policy permits it.
- [ ] call PostHog reset on logout.

## Screen analytics

- [ ] Track meaningful product screen names explicitly.
- [ ] Avoid relying solely on internal SwiftUI view class names.

## Offline behavior

- [ ] Verify events queue offline and flush after reconnect.
- [ ] Avoid duplicating events when app state is retried.

## Marketing funnel

Recommended in the same milestone or a small follow-up:

- [ ] Add lightweight PostHog web tracking to `apps/web`.
- [ ] Track `landing_viewed`.
- [ ] Track `app_store_cta_clicked`.
- [ ] Preserve UTM/referrer properties for acquisition attribution.

## Quality gate

- [ ] Events appear in a non-production PostHog project.
- [ ] Anonymous events become associated with the authenticated backend user after identify.
- [ ] Logout resets identity.
- [ ] Offline capture/flush is verified.
- [ ] No task/habit free-form content appears in captured event payloads.
- [ ] Analytics can be disabled by removing configuration.

---

# Phase 8 — RevenueCat ↔ backend entitlement synchronization

Goal: make server-side subscription state trustworthy before any API feature depends on Pro access.

## Webhook endpoint

- [ ] Add a dedicated Hono RevenueCat webhook route.
- [ ] Verify a configured shared authorization secret.
- [ ] Store processed webhook event IDs.
- [ ] Make webhook processing idempotent.
- [ ] Persist current entitlement state per backend user.
- [ ] Keep client RevenueCat checks for immediate UX.

## Account mapping

- [ ] Set RevenueCat app user ID to the stable backend user ID after authentication.
- [ ] Handle anonymous → authenticated RevenueCat identity transition.
- [ ] Document logout behavior.

## Quality gate

- [ ] Duplicate webhook delivery produces one logical update.
- [ ] Purchase updates backend entitlement state.
- [ ] Cancellation/expiration updates backend state.
- [ ] Restore on a second device maps to the same backend user.
- [ ] Server can answer whether a user has the configured Pro entitlement.
- [ ] No premium API gating is added until this gate passes.

---

# Phase 9 — Production API/database deployment

Goal: deploy the Bun/Hono backend with a SQLite topology that is actually safe for production.

## SQLite production topology decision

Local `bun:sqlite` is excellent for development. Production requires an explicit decision.

### Option A — Single Bun instance + persistent volume

Suitable while traffic is small and architecture stays simple.

Requirements:

- [ ] exactly one writer/API instance
- [ ] persistent volume
- [ ] WAL mode reviewed/configured
- [ ] automated backups
- [ ] restore procedure tested
- [ ] no horizontal replicas writing the same file

### Option B — Remote SQLite-compatible service

Use when multi-instance or simpler operational durability is needed.

Drizzle can remain the ORM, but the driver may change (for example to a libSQL-compatible backend).

Decision gate:

- [ ] deployment topology documented before production launch
- [ ] no ephemeral container filesystem used for the production database

## Deployment hardening

- [ ] production/staging environments.
- [ ] secrets injected by deployment platform.
- [ ] migrations run as an explicit deployment step.
- [ ] health/readiness endpoint.
- [ ] request size limits.
- [ ] rate limits on auth/write endpoints.
- [ ] production CORS policy for known web origins only where needed.
- [ ] structured logs.
- [ ] no stack traces returned to clients.
- [ ] database backup schedule.
- [ ] documented rollback/restore procedure.

## Quality gate

- [ ] staging boots from a blank database via committed migrations.
- [ ] production-like backup can be restored into a clean environment.
- [ ] health endpoint works during deployment.
- [ ] auth/task sync smoke tests pass against staging.
- [ ] secrets are absent from repository and client bundles.
- [ ] database survives application redeployment.

---

# Phase 10 — Monorepo CI/CD hardening

Goal: make every layer independently testable while keeping CI economical.

## Jobs

### iOS / macOS

- [ ] Swift build-for-testing.
- [ ] unit tests.
- [ ] UI-test target compile.
- [ ] optional full UI test job.
- [ ] release preflight checks where applicable.

### API / Linux

- [ ] `bun install --frozen-lockfile`.
- [ ] typecheck.
- [ ] unit tests.
- [ ] DB integration tests.
- [ ] migration-from-zero test.

### Web / Linux

- [ ] typecheck.
- [ ] `astro check`.
- [ ] production build.
- [ ] optional Lighthouse CI.

### Contracts

- [ ] schema package typecheck/tests.
- [ ] API contract fixtures tested against iOS Codable expectations where practical.

## CI ergonomics

- [ ] preserve concurrency cancellation.
- [ ] split macOS and Linux work so web/API do not consume macOS runners.
- [ ] add path-aware jobs only after the basic matrix is stable.
- [ ] use normal dependency caching before considering Turborepo.

## Quality gate

- [ ] one root documentation section explains every CI job.
- [ ] each CI command can be reproduced locally.
- [ ] failure in one workspace identifies the owning app clearly.
- [ ] CI contains no production credentials.
- [ ] Turborepo still absent unless its adoption gate has been met.

---

# Phase 11 — Release candidate / production launch

Goal: prove the whole system works as one product.

## End-to-end acceptance path

- [ ] install app fresh.
- [ ] complete onboarding.
- [ ] sign in.
- [ ] create task offline.
- [ ] reconnect and sync.
- [ ] see the task after reinstall/sign-in on another device.
- [ ] create/complete a habit.
- [ ] verify check-in/insights.
- [ ] view paywall.
- [ ] purchase/restore subscription in the correct test environment.
- [ ] verify RevenueCat entitlement.
- [ ] verify backend entitlement mirror.
- [ ] verify PostHog funnel events.
- [ ] open marketing site.
- [ ] follow App Store/TestFlight CTA.

## App Store readiness

- [ ] production app icon/screenshots.
- [ ] real Terms URL.
- [ ] real Privacy URL.
- [ ] real Support URL.
- [ ] privacy manifest reviewed.
- [ ] App Store privacy labels reviewed.
- [ ] subscription disclosures match RevenueCat/App Store Connect.
- [ ] account deletion path works when accounts are enabled.
- [ ] notification permission UX reviewed.
- [ ] accessibility pass.
- [ ] Dynamic Type pass.
- [ ] localization readiness pass.
- [ ] `scripts/preflight.sh` passes.

## Infrastructure

- [ ] production API deployed.
- [ ] production DB topology documented.
- [ ] backup/restore tested.
- [ ] marketing site deployed.
- [ ] production PostHog project configured.
- [ ] production RevenueCat project/config configured.
- [ ] production auth credentials configured.
- [ ] staging remains available for regression testing.

## Final quality gate

A release candidate is production-ready only when:

- [ ] iOS CI passes.
- [ ] API CI passes.
- [ ] web CI passes.
- [ ] end-to-end acceptance path passes.
- [ ] no placeholder configuration remains.
- [ ] no development/mock provider is reachable in Release.
- [ ] offline task usage still works.
- [ ] authenticated cloud sync works.
- [ ] subscription restoration works.
- [ ] analytics contains no user-created task/habit content.
- [ ] database restore procedure has been demonstrated.

---

# Deferred until after production v1

Do not add these merely because the monorepo makes them possible:

- [ ] Turborepo, unless its adoption gate is met.
- [ ] GraphQL.
- [ ] microservices.
- [ ] Kafka/event bus.
- [ ] generic repository/DI frameworks in Swift.
- [ ] web account dashboard.
- [ ] admin dashboard.
- [ ] real-time collaborative task updates.
- [ ] multi-region database architecture.
- [ ] feature flag framework unless there is a concrete experiment/rollout.
- [ ] background push-driven sync unless normal foreground sync is insufficient.
- [ ] custom analytics backend.
- [ ] Kubernetes.

---

# Milestone dependency map

```text
1. Monorepo foundation
        ↓
2. API + local SQLite
        ↓
3. Production identity
        ↓
4. Task sync
        ↓
5. Habit/check-in sync
        ↓
8. RevenueCat backend entitlement
        ↓
9. Production API/DB deployment
        ↓
11. Release candidate

6. Marketing web ───────────────┐
                               ├──→ 11. Release candidate
7. PostHog analytics ──────────┘

10. CI/CD hardening evolves alongside phases 1–9
and must be complete before phase 11.
```

---

# Recommended PR sequence

Keep PRs small enough that one concern can be reviewed and reverted independently.

1. **Monorepo: move iOS under apps/ios**
2. **Monorepo: Bun workspaces + root scripts**
3. **API: Hono + Drizzle + local SQLite + task CRUD**
4. **Auth: production Sign in with Apple + API session**
5. **Sync: tasks local-first SwiftData ↔ API**
6. **Sync: habits + check-ins**
7. **Web: Astro marketing one-pager**
8. **Analytics: PostHog iOS + event taxonomy**
9. **Analytics: landing acquisition events**
10. **Billing: RevenueCat webhook + backend entitlement mirror**
11. **Infra: production API + SQLite topology + backups**
12. **CI: final path-aware matrix / release checks**
13. **Release: TestFlight + production acceptance**

A PR must not start the next architectural dependency until the previous milestone's quality gate is green.

---

# Reference implementation sources

Validated against current official documentation when this roadmap was written:

- Bun workspaces: https://bun.sh/docs/pm/workspaces
- Bun workspace filtering/scripts: https://bun.sh/docs/pm/filter
- Hono on Bun: https://hono.dev/docs/getting-started/bun
- Drizzle + Bun SQLite: https://orm.drizzle.team/docs/get-started/bun-sqlite-new
- Drizzle Studio: https://orm.drizzle.team/docs/drizzle-kit-studio
- Astro React integration: https://docs.astro.build/en/guides/integrations-guide/react/
- Astro + Tailwind CSS: https://docs.astro.build/en/guides/styling/
- shadcn/ui + Astro: https://ui.shadcn.com/docs/installation/astro
- PostHog iOS SDK: https://posthog.com/docs/libraries/ios

Use compatible current stable versions when each milestone is implemented; do not hardcode roadmap-era package versions into future PRs without re-verifying them.
