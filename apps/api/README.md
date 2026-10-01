# Routine API

Small Bun API using Hono, Better Auth, Drizzle, and Bun's SQLite driver.

## Run locally

1. Copy `.env.example` to `.env` and set `BETTER_AUTH_SECRET` to a random value of at least 32 characters. For example, use `openssl rand -base64 32`.
2. Apply the checked-in SQLite migrations with `bun run db:migrate`.
3. Start the server with `bun run dev`.

The API binds to `127.0.0.1:3001` by default. The local database is `data/routine.sqlite` and is ignored by Git. To listen inside a container, set `API_HOST=0.0.0.0` and expose the port through a trusted HTTPS proxy.

## Routes

- `GET /docs` serves an interactive API reference for app and authentication routes.
- `GET /openapi.json` serves the OpenAPI document for app-owned routes.
- `GET /healthz` returns `{ "status": "ok" }`.
- `GET /api/me` returns the current user's public profile or `401`.
- Better Auth handles `GET` and `POST /api/auth/*`, including OAuth callbacks.

Better Auth generates its authentication schema at
`GET /api/auth/open-api/generate-schema`; the Scalar reference includes it as a
separate source.

From a web or mobile client, start social sign-in with Better Auth's client:

```ts
import { createAuthClient } from "better-auth/client";

const authClient = createAuthClient({ baseURL: "http://localhost:3001" });
await authClient.signIn.social({ provider: "google" });
await authClient.signIn.social({ provider: "apple" });
```

The API only enables a provider after all of that provider's credentials are set. With no provider secrets, health and session routes still run.

## OAuth setup

For Google, set `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET`, then register `http://localhost:3001/api/auth/callback/google` as an authorized redirect URI. Replace the localhost URI with the public HTTPS API origin in production.

For Apple, set the Service ID in `APPLE_CLIENT_ID`, and provide `APPLE_TEAM_ID`, `APPLE_KEY_ID`, the `.p8` key in `APPLE_PRIVATE_KEY`, and the native app bundle ID in `APPLE_APP_BUNDLE_IDENTIFIER`. The server signs and refreshes Apple's client-secret JWT at runtime. Apple Sign In needs a valid HTTPS domain for web callbacks; localhost is not supported. Add that domain and the callback URI in Apple's developer portal. The API also accepts the explicitly configured custom mobile callback origin through `TRUSTED_ORIGINS`.

Set `BETTER_AUTH_URL` to the public HTTPS API origin in production. `TRUSTED_ORIGINS` is a comma-separated allowlist for client origins; its local default is the Astro dev server. Do not put provider secrets in tracked files.

## Security defaults

- Exact CORS and Better Auth origin allowlists; credentials are enabled only for those origins.
- Hono security headers and a 1 MiB request-body limit.
- A 120-request/minute API limit keyed by Bun's socket IP, plus Better Auth's 100-request/minute limit and a 10-request/minute social sign-in rule. The API overwrites client-supplied forwarded-IP headers before Better Auth sees them.
- Implicit cross-provider account linking is disabled. Users can explicitly link another provider from an authenticated client.
- The rate-limit stores are process-local and use the socket peer IP. Multiple instances need shared rate-limit storage; deployments behind a proxy also need explicit trusted-proxy IP handling before trusting forwarded headers.

## Database

`src/db/schema.ts` is generated from the Better Auth configuration. Use `bun run db:generate` after changing auth schema, then review and commit the generated migration. Apply migrations with `bun run db:migrate`; the API does not modify the schema automatically at startup.
