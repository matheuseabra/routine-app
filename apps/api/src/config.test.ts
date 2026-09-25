import { describe, expect, test } from "bun:test";
import { loadConfig } from "./config";

const secret = "a-secure-test-secret-that-is-long-enough";

describe("loadConfig", () => {
  test("uses safe local defaults and leaves providers disabled", () => {
    const config = loadConfig({ BETTER_AUTH_SECRET: secret });

    expect(config.host).toBe("127.0.0.1");
    expect(config.port).toBe(3001);
    expect(config.authUrl).toBe("http://localhost:3001");
    expect(config.google).toBeUndefined();
    expect(config.apple).toBeUndefined();
  });

  test("requires a complete provider configuration", () => {
    expect(() =>
      loadConfig({
        BETTER_AUTH_SECRET: secret,
        GOOGLE_CLIENT_ID: "google-client-id",
      }),
    ).toThrow("Set both GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET.");
  });

  test("requires HTTPS for a non-local production auth URL", () => {
    expect(() =>
      loadConfig({
        NODE_ENV: "production",
        BETTER_AUTH_SECRET: secret,
        BETTER_AUTH_URL: "http://api.example.com",
      }),
    ).toThrow("BETTER_AUTH_URL must use HTTPS outside local development.");
  });
});
