import { mkdirSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { Database } from "bun:sqlite";
import { drizzle } from "drizzle-orm/bun-sqlite";
import * as schema from "./schema";

export function createDatabase(databasePath: string) {
  const filename =
    databasePath === ":memory:"
      ? databasePath
      : resolve(import.meta.dir, "../..", databasePath);
  if (filename !== ":memory:") mkdirSync(dirname(filename), { recursive: true });

  const client = new Database(filename);
  client.exec("PRAGMA foreign_keys = ON");
  client.exec("PRAGMA journal_mode = WAL");
  client.exec("PRAGMA busy_timeout = 5000");

  return {
    client,
    db: drizzle({ client, schema }),
    close: () => client.close(),
  };
}

export type ApiDatabase = ReturnType<typeof createDatabase>["db"];
