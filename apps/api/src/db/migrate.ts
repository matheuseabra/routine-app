import { resolve } from "node:path";
import { migrate } from "drizzle-orm/bun-sqlite/migrator";
import { createDatabase } from ".";

const databasePath = Bun.env.DATABASE_PATH?.trim() || "data/routine.sqlite";
const database = createDatabase(databasePath);

try {
  migrate(database.db, {
    migrationsFolder: resolve(import.meta.dir, "../../drizzle"),
  });
  console.info("SQLite migrations applied.");
} finally {
  database.close();
}
