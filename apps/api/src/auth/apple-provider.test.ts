import { describe, expect, test } from "bun:test";
import { exportPKCS8, generateKeyPair, jwtVerify } from "jose";
import { createAppleProvider } from "./apple-provider";

describe("Apple provider credentials", () => {
  test("creates and caches a valid Apple client-secret JWT", async () => {
    const { privateKey, publicKey } = await generateKeyPair("ES256", {
      extractable: true,
    });
    const credentials = {
      clientId: "com.example.web",
      teamId: "TEAM123456",
      keyId: "KEY1234567",
      privateKey: await exportPKCS8(privateKey),
      appBundleIdentifier: "com.example.ios",
    };
    const provider = createAppleProvider(credentials);
    const first = await provider();
    const second = await provider();
    const { payload, protectedHeader } = await jwtVerify(
      first.clientSecret,
      publicKey,
      {
        issuer: credentials.teamId,
        subject: credentials.clientId,
        audience: "https://appleid.apple.com",
      },
    );

    expect(second.clientSecret).toBe(first.clientSecret);
    expect(protectedHeader).toMatchObject({ alg: "ES256", kid: credentials.keyId });
    expect(payload.exp! - payload.iat!).toBe(180 * 24 * 60 * 60);
    expect(first.appBundleIdentifier).toBe(credentials.appBundleIdentifier);
  });
});
