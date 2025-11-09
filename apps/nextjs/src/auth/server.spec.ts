import { describe, expect, it } from "vitest";

import { resolveBaseUrl } from "./base-url";

const baseEnv = {
  VERCEL_ENV: "development",
  VERCEL_PROJECT_PRODUCTION_URL: "prod.acme.test",
  VERCEL_URL: "preview.acme.test",
};

describe("resolveBaseUrl", () => {
  it("prefers the production domain", () => {
    const url = resolveBaseUrl({
      ...baseEnv,
      VERCEL_ENV: "production",
    });

    expect(url).toBe(`https://${baseEnv.VERCEL_PROJECT_PRODUCTION_URL}`);
  });

  it("uses the preview deployment domain when available", () => {
    const url = resolveBaseUrl({
      ...baseEnv,
      VERCEL_ENV: "preview",
    });

    expect(url).toBe(`https://${baseEnv.VERCEL_URL}`);
  });

  it("falls back to localhost for dev/test environments", () => {
    const url = resolveBaseUrl({
      ...baseEnv,
      VERCEL_ENV: "development",
    });

    expect(url).toBe("http://localhost:3000");
  });
});
