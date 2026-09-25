import { createApiApp } from "./app";
import { createAuth } from "./auth";
import { loadConfig } from "./config";
import { createDatabase } from "./db";

const config = loadConfig();
const database = createDatabase(config.databasePath);
const auth = createAuth(config, database.db);
const app = createApiApp({ auth, corsOrigins: config.corsOrigins });

const server = Bun.serve({
  hostname: config.host,
  port: config.port,
  fetch(request, server) {
    const clientIp = server.requestIP(request)?.address ?? "unknown";
    const headers = new Headers(request.headers);
    headers.delete("x-forwarded-for");
    headers.set("x-real-ip", clientIp);
    return app.fetch(new Request(request, { headers }), { clientIp });
  },
});

console.info(`Routine API listening at http://${config.host}:${server.port}`);
