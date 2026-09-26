import { describe, expect, test } from "bun:test";
import { resolve } from "node:path";
import { migrate } from "drizzle-orm/bun-sqlite/migrator";
import { createDatabase } from ".";

describe("SQLite migrations", () => {
  test("creates the Better Auth tables with Bun's SQLite driver", () => {
    const database = createDatabase(":memory:");

    try {
      const migrationsFolder = resolve(import.meta.dir, "../../drizzle");
      migrate(database.db, { migrationsFolder });
      const tables = database.client
        .query("SELECT name FROM sqlite_master WHERE type = 'table'")
        .all() as Array<{ name: string }>;

      expect(tables.map((table) => table.name)).toEqual(
        expect.arrayContaining(["user", "session", "account", "verification"]),
      );
    } finally {
      database.close();
    }
  });
});
