import { Hono } from "hono";

const app = new Hono();

app.get("/healthz", (context) => context.json({ status: "ok" }));

export default {
  port: Number(Bun.env.PORT ?? 3001),
  fetch: app.fetch,
};
