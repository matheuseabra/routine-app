import type { MiddlewareHandler } from "hono";

type ApiEnvironment = {
  Bindings: { clientIp?: string };
};

type Bucket = { count: number; resetAt: number };

export type RateLimitOptions = {
  windowMs: number;
  max: number;
  maxKeys?: number;
  now?: () => number;
};

function removeExpired(buckets: Map<string, Bucket>, now: number): void {
  for (const [key, bucket] of buckets) {
    if (bucket.resetAt <= now) buckets.delete(key);
  }
}

export function createRateLimiter(
  options: RateLimitOptions,
): MiddlewareHandler<ApiEnvironment> {
  if (options.windowMs < 1 || options.max < 1) {
    throw new RangeError("Rate limit window and maximum must be positive.");
  }

  const maxKeys = options.maxKeys ?? 10_000;
  const clock = options.now ?? Date.now;
  const buckets = new Map<string, Bucket>();
  let lastCleanup = 0;

  return async (context, next) => {
    const now = clock();
    if (now - lastCleanup >= options.windowMs) {
      removeExpired(buckets, now);
      lastCleanup = now;
    }

    const key = context.env?.clientIp || "unknown";
    let bucket = buckets.get(key);
    if (!bucket || bucket.resetAt <= now) {
      if (buckets.size >= maxKeys) {
        removeExpired(buckets, now);
        if (buckets.size >= maxKeys) {
          return context.json({ error: "rate_limit_capacity" }, 503);
        }
      }
      bucket = { count: 0, resetAt: now + options.windowMs };
      buckets.set(key, bucket);
    }

    if (bucket.count >= options.max) {
      const seconds = Math.max(1, Math.ceil((bucket.resetAt - now) / 1000));
      context.header("Retry-After", String(seconds));
      return context.json({ error: "rate_limited" }, 429);
    }

    bucket.count += 1;
    context.header("RateLimit-Limit", String(options.max));
    context.header("RateLimit-Remaining", String(options.max - bucket.count));
    context.header("RateLimit-Reset", String(Math.ceil(bucket.resetAt / 1000)));
    await next();
  };
}
