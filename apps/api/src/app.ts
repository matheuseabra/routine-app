import { OpenAPIHono, createRoute, z } from "@hono/zod-openapi";
import { Scalar } from "@scalar/hono-api-reference";
import { bodyLimit } from "hono/body-limit";
import { cors } from "hono/cors";
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

const healthRoute = createRoute({
  method: "get",
  path: "/healthz",
  tags: ["System"],
  summary: "Check API health",
  responses: {
    200: {
      description: "The API is healthy.",
      content: {
        "application/json": {
          schema: z.object({ status: z.literal("ok") }),
        },
      },
    },
  },
});

const currentUserSchema = z.object({
  user: z.object({
    id: z.string(),
    name: z.string(),
    email: z.string(),
    emailVerified: z.boolean(),
    image: z.string().nullable().optional(),
  }),
});

const errorSchema = z.object({ error: z.string() });

const currentUserRoute = createRoute({
  method: "get",
  path: "/api/me",
  tags: ["Account"],
  summary: "Get the current user",
  responses: {
    200: {
      description: "The authenticated user's account details.",
      content: { "application/json": { schema: currentUserSchema } },
    },
    401: {
      description: "No authenticated session was found.",
      content: { "application/json": { schema: errorSchema } },
    },
  },
});

export function createApiApp(options: ApiAppOptions) {
  const app = new OpenAPIHono<ApiEnvironment>();

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

  app.openapi(healthRoute, (context) => context.json({ status: "ok" }));
  app.all("/api/auth/*", (context) => options.auth.handler(context.req.raw));
  app.openapi(currentUserRoute, async (context) => {
    const session = await options.auth.api.getSession({
      headers: context.req.raw.headers,
    });
    if (!session) return context.json({ error: "unauthorized" }, 401 as const);
    return context.json({ user: session.user }, 200 as const);
  });

  app.doc("/openapi.json", {
    openapi: "3.0.0",
    info: {
      title: "Routine API",
      version: "1.0.0",
      description: "The API for the Routine app.",
    },
  });
  app.get(
    "/docs",
    Scalar({
      pageTitle: "Routine API reference",
      sources: [
        { url: "/openapi.json", title: "Routine API" },
        {
          url: "/api/auth/open-api/generate-schema",
          title: "Authentication API",
        },
      ],
    }),
  );

  app.notFound((context) => context.json({ error: "not_found" }, 404));
  app.onError(() => new Response('{"error":"internal_error"}', {
    status: 500,
    headers: { "Content-Type": "application/json; charset=UTF-8" },
  }));

  return app;
}
