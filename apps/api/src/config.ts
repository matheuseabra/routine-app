export type GoogleCredentials = {
  clientId: string;
  clientSecret: string;
};

export type AppleCredentials = {
  clientId: string;
  teamId: string;
  keyId: string;
  privateKey: string;
  appBundleIdentifier: string;
};

export type ApiConfig = {
  mode: string;
  host: string;
  port: number;
  databasePath: string;
  authUrl: string;
  authSecret: string;
  corsOrigins: string[];
  google?: GoogleCredentials;
  apple?: AppleCredentials;
};

type Environment = Record<string, string | undefined>;

function readGoogleCredentials(env: Environment): GoogleCredentials | undefined {
  const clientId = env.GOOGLE_CLIENT_ID?.trim() ?? "";
  const clientSecret = env.GOOGLE_CLIENT_SECRET?.trim() ?? "";
  if (!clientId && !clientSecret) return undefined;
  if (!clientId || !clientSecret) {
    throw new Error("Set both GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET.");
  }
  return { clientId, clientSecret };
}

function readAppleCredentials(env: Environment): AppleCredentials | undefined {
  const values = [
    env.APPLE_CLIENT_ID?.trim() ?? "",
    env.APPLE_TEAM_ID?.trim() ?? "",
    env.APPLE_KEY_ID?.trim() ?? "",
    env.APPLE_PRIVATE_KEY?.trim() ?? "",
    env.APPLE_APP_BUNDLE_IDENTIFIER?.trim() ?? "",
  ];
  const completeValues = requireAppleCredentials(values);
  if (!completeValues) return undefined;
  const [clientId, teamId, keyId, privateKey, appBundleIdentifier] = completeValues;
  return {
    clientId,
    teamId,
    keyId,
    privateKey: privateKey.replaceAll("\\n", "\n"),
    appBundleIdentifier,
  };
}

function requireAppleCredentials(
  values: string[],
): string[] | undefined {
  const configured = values.filter(Boolean).length;
  if (configured === 0) return undefined;
  if (configured !== values.length) {
    throw new Error(
      "Set APPLE_CLIENT_ID, APPLE_TEAM_ID, APPLE_KEY_ID, APPLE_PRIVATE_KEY, and APPLE_APP_BUNDLE_IDENTIFIER together.",
    );
  }
  return values;
}

function parsePort(value: string | undefined): number {
  const port = Number(value ?? 3001);
  if (!Number.isInteger(port) || port < 1 || port > 65535) {
    throw new Error("PORT must be an integer between 1 and 65535.");
  }
  return port;
}

function parseAuthUrl(value: string, mode: string): string {
  let url: URL;
  try {
    url = new URL(value);
  } catch {
    throw new Error("BETTER_AUTH_URL must be a valid URL origin.");
  }
  const localHttp =
    url.protocol === "http:" &&
    ["localhost", "127.0.0.1", "[::1]"].includes(url.hostname);
  if (url.protocol !== "https:" && !(mode !== "production" && localHttp)) {
    throw new Error("BETTER_AUTH_URL must use HTTPS outside local development.");
  }
  if (url.pathname !== "/" || url.search || url.hash) {
    throw new Error("BETTER_AUTH_URL must contain only the origin, without a path.");
  }
  return url.origin;
}

function validateOrigin(value: string, mode: string): string {
  let url: URL;
  try {
    url = new URL(value);
  } catch {
    throw new Error(`Invalid TRUSTED_ORIGINS entry: ${value}`);
  }
  const webOrigin = url.protocol === "http:" || url.protocol === "https:";
  const localHttp =
    url.protocol === "http:" &&
    ["localhost", "127.0.0.1", "[::1]"].includes(url.hostname);
  if (mode === "production" && url.protocol === "http:" && !localHttp) {
    throw new Error("Production TRUSTED_ORIGINS entries must use HTTPS.");
  }
  if (webOrigin && (url.pathname !== "/" || url.search || url.hash)) {
    throw new Error("Web TRUSTED_ORIGINS entries must be origins without paths.");
  }
  return webOrigin ? url.origin : value;
}

function readCorsOrigins(env: Environment, mode: string): string[] {
  const raw = env.TRUSTED_ORIGINS ?? "http://localhost:4321";
  const origins = raw.split(",").map((value) => value.trim()).filter(Boolean);
  if (origins.length === 0) throw new Error("TRUSTED_ORIGINS must include an origin.");
  return [...new Set(origins.map((origin) => validateOrigin(origin, mode)))];
}

function readSecret(value: string | undefined): string {
  const secret = value?.trim() ?? "";
  if (secret.length < 32) {
    throw new Error("Set BETTER_AUTH_SECRET to a random value of at least 32 characters.");
  }
  return secret;
}

export function loadConfig(env: Environment = Bun.env): ApiConfig {
  const mode = env.NODE_ENV ?? "development";
  const authUrl = parseAuthUrl(
    env.BETTER_AUTH_URL ?? "http://localhost:3001",
    mode,
  );
  return {
    mode,
    host: env.API_HOST?.trim() || "127.0.0.1",
    port: parsePort(env.PORT),
    databasePath: env.DATABASE_PATH?.trim() || "data/routine.sqlite",
    authUrl,
    authSecret: readSecret(env.BETTER_AUTH_SECRET),
    corsOrigins: readCorsOrigins(env, mode),
    google: readGoogleCredentials(env),
    apple: readAppleCredentials(env),
  };
}
