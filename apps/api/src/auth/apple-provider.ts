import { importPKCS8, SignJWT } from "jose";
import type { AppleCredentials } from "../config";

const secretLifetimeSeconds = 180 * 24 * 60 * 60;
const refreshMarginMs = 24 * 60 * 60 * 1000;

export function createAppleProvider(credentials: AppleCredentials) {
  let signingKey: ReturnType<typeof importPKCS8> | undefined;
  let pendingSecret: Promise<string> | undefined;
  let cachedSecret: { value: string; refreshAt: number } | undefined;

  async function getClientSecret(): Promise<string> {
    if (cachedSecret && cachedSecret.refreshAt > Date.now()) {
      return cachedSecret.value;
    }
    signingKey ??= importPKCS8(credentials.privateKey, "ES256");
    pendingSecret ??= (async () => {
      const now = Math.floor(Date.now() / 1000);
      const key = await signingKey;
      return new SignJWT({})
        .setProtectedHeader({ alg: "ES256", kid: credentials.keyId })
        .setIssuer(credentials.teamId)
        .setSubject(credentials.clientId)
        .setAudience("https://appleid.apple.com")
        .setIssuedAt(now)
        .setExpirationTime(now + secretLifetimeSeconds)
        .sign(key);
    })();
    try {
      const value = await pendingSecret;
      cachedSecret = {
        value,
        refreshAt: Date.now() + secretLifetimeSeconds * 1000 - refreshMarginMs,
      };
      return value;
    } finally {
      pendingSecret = undefined;
    }
  }

  return async () => ({
    clientId: credentials.clientId,
    clientSecret: await getClientSecret(),
    appBundleIdentifier: credentials.appBundleIdentifier,
  });
}
