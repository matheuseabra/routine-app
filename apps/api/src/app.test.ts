import { describe, expect, test } from "bun:test";
import { createApiApp, type AuthPort } from "./app";

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
