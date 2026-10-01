import { betterAuth } from "better-auth/minimal";
import { drizzleAdapter } from "better-auth/adapters/drizzle";
import { openAPI } from "better-auth/plugins";
import type { ApiConfig } from "../config";
import type { ApiDatabase } from "../db";
import * as schema from "../db/schema";
import { createAppleProvider } from "./apple-provider";

export function createAuth(config: ApiConfig, db: ApiDatabase) {
  const socialProviders = {
    ...(config.google ? { google: config.google } : {}),
    ...(config.apple ? { apple: createAppleProvider(config.apple) } : {}),
  };

  return betterAuth({
    appName: "Routine",
    baseURL: config.authUrl,
    basePath: "/api/auth",
    secret: config.authSecret,
    database: drizzleAdapter(db, { provider: "sqlite", schema }),
    emailAndPassword: { enabled: false },
    plugins: [openAPI({ disableDefaultReference: true })],
    socialProviders,
    trustedOrigins: [
      ...config.corsOrigins,
      config.authUrl,
      "https://appleid.apple.com",
    ],
    account: {
      accountLinking: { enabled: true, disableImplicitLinking: true },
    },
    rateLimit: {
      enabled: true,
      window: 60,
      max: 100,
      customRules: { "/sign-in/social": { window: 60, max: 10 } },
    },
    advanced: {
      ipAddress: { ipAddressHeaders: ["x-real-ip"] },
    },
  });
}
