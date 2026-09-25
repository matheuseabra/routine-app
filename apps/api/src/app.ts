import { bodyLimit } from "hono/body-limit";
import { cors } from "hono/cors";
import { Hono } from "hono";
import { secureHeaders } from "hono/secure-headers";
import { createRateLimiter, type RateLimitOptions } from "./middleware/rate-limit";

export type ApiEnvironment = {
  Bindings: { clientIp?: string };
};

export type AuthSession = {
  user: {
    id: string;
    name: string;
    email: string;
    emailVerified: boolean;
    image?: string | null;
  };
};

export type AuthPort = {
  handler: (request: Request) => Response | Promise<Response>;
  api: {
    getSession: (input: { headers: Headers }) => Promise<AuthSession | null>;
  };
};

export type ApiAppOptions = {
  auth: AuthPort;
  corsOrigins: string[];
  rateLimit?: RateLimitOptions;
};

export function createApiApp(options: ApiAppOptions) {
  const app = new Hono<ApiEnvironment>();

  app.use("*", secureHeaders());
  app.use("/api/*", bodyLimit({ maxSize: 1024 * 1024 }));
  app.use(
    "/api/*",
    cors({
      origin: options.corsOrigins,
      allowHeaders: ["Authorization", "Content-Type"],
      allowMethods: ["GET", "POST", "OPTIONS"],
      credentials: true,
      maxAge: 600,
    }),
  );
  app.use(
    "/api/*",
    createRateLimiter(
      options.rateLimit ?? { windowMs: 60_000, max: 120 },
    ),
  );

  app.get("/healthz", (context) => context.json({ status: "ok" }));
  app.all("/api/auth/*", (context) => options.auth.handler(context.req.raw));
  app.get("/api/me", async (context) => {
    const session = await options.auth.api.getSession({
      headers: context.req.raw.headers,
    });
    if (!session) return context.json({ error: "unauthorized" }, 401);
    return context.json({ user: session.user });
  });

  app.notFound((context) => context.json({ error: "not_found" }, 404));
  app.onError(() => new Response('{"error":"internal_error"}', {
    status: 500,
    headers: { "Content-Type": "application/json; charset=UTF-8" },
  }));

  return app;
}
