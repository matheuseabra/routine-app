import { describe, expect, test } from "bun:test";
import { createApiApp, type AuthPort } from "./app";
import { createAuth } from "./auth";
import { loadConfig } from "./config";
import { createDatabase } from "./db";

function makeAuth(session: boolean): AuthPort {
  return {
    handler: () => Response.json({ auth: "handled" }),
    api: {
      getSession: async () =>
        session
          ? {
              user: {
                id: "user-1",
                name: "Routine User",
                email: "user@example.com",
                emailVerified: true,
              },
            }
          : null,
    },
  };
}

describe("API app", () => {
  test("serves health with security headers", async () => {
    const app = createApiApp({ auth: makeAuth(false), corsOrigins: [] });
    const response = await app.request("/healthz");

    expect(response.status).toBe(200);
    expect(await response.json()).toEqual({ status: "ok" });
    expect(response.headers.get("x-content-type-options")).toBe("nosniff");
  });

  test("publishes an OpenAPI document for app-owned routes", async () => {
    const app = createApiApp({ auth: makeAuth(false), corsOrigins: [] });
    const response = await app.request("/openapi.json");
    const document = await response.json();

    expect(response.status).toBe(200);
    expect(document.openapi).toBe("3.0.0");
    expect(document.info.title).toBe("Routine API");
    expect(document.paths["/healthz"].get.summary).toBe("Check API health");
    expect(document.paths["/api/me"].get.responses["401"]).toBeDefined();
  });

  test("serves Scalar documentation for app and authentication APIs", async () => {
    const app = createApiApp({ auth: makeAuth(false), corsOrigins: [] });
    const response = await app.request("/docs");
    const html = await response.text();

    expect(response.status).toBe(200);
    expect(response.headers.get("content-type")).toContain("text/html");
    expect(html).toContain("Routine API reference");
    expect(html).toContain("/openapi.json");
    expect(html).toContain("/api/auth/open-api/generate-schema");
  });

  test("generates an OpenAPI schema for Better Auth routes", async () => {
    const database = createDatabase(":memory:");
    const auth = createAuth(
      loadConfig({
        BETTER_AUTH_SECRET: "test-secret-that-is-long-enough-for-tests",
      }),
      database.db,
    );
    const app = createApiApp({ auth, corsOrigins: [] });

    try {
      const response = await app.request(
        "/api/auth/open-api/generate-schema",
      );
      const document = await response.json();

      expect(response.status).toBe(200);
      expect(document.openapi).toBe("3.1.1");
      expect(document.paths["/sign-in/social"]).toBeDefined();
      expect(document.paths["/get-session"]).toBeDefined();
    } finally {
      database.close();
    }
  });

  test("protects the current-user route and returns only the user", async () => {
    const unauthorized = createApiApp({
      auth: makeAuth(false),
      corsOrigins: [],
    });
    const denied = await unauthorized.request("/api/me");
    expect(denied.status).toBe(401);

    const authorized = createApiApp({
      auth: makeAuth(true),
      corsOrigins: [],
    });
    const response = await authorized.request("/api/me");
    expect(response.status).toBe(200);
    expect(await response.json()).toEqual({
      user: {
        id: "user-1",
        name: "Routine User",
        email: "user@example.com",
        emailVerified: true,
      },
    });
  });

  test("forwards Better Auth routes and applies the API rate limit", async () => {
    const app = createApiApp({
      auth: makeAuth(false),
      corsOrigins: [],
      rateLimit: { windowMs: 60_000, max: 2 },
    });
    const authResponse = await app.request("/api/auth/get-session");
    expect(await authResponse.json()).toEqual({ auth: "handled" });

    const request = () =>
      app.fetch(new Request("http://localhost/api/me"), { clientIp: "192.0.2.1" });
    expect((await request()).status).toBe(401);
    expect((await request()).status).toBe(401);
    const limited = await request();
    expect(limited.status).toBe(429);
    expect(limited.headers.get("retry-after")).not.toBeNull();
  });
});
