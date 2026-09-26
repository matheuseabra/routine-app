import { mkdirSync } from "node:fs";
import { dirname, isAbsolute, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { defineConfig } from "drizzle-kit";

const configDirectory = dirname(fileURLToPath(import.meta.url));
const configuredPath = process.env.DATABASE_PATH?.trim() || "data/routine.sqlite";
const databasePath =
  configuredPath === ":memory:"
    ? configuredPath
    : isAbsolute(configuredPath)
      ? configuredPath
      : resolve(configDirectory, configuredPath);
if (databasePath !== ":memory:") {
  mkdirSync(dirname(databasePath), { recursive: true });
}

export default defineConfig({
  dialect: "sqlite",
  schema: "./src/db/schema.ts",
  out: "./drizzle",
  dbCredentials: { url: databasePath },
});
