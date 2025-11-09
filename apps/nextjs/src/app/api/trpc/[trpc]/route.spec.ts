import type { NextRequest } from "next/server";
import { describe, expect, it, beforeEach, vi } from "vitest";

const mocks = vi.hoisted(() => {
  return {
    fetchRequestHandler: vi.fn(async () => new Response("ok", { status: 200 })),
    createTRPCContext: vi.fn(async () => ({ session: null })),
    auth: { mocked: true },
    appRouter: { _def: {} },
  };
});

vi.mock("@trpc/server/adapters/fetch", () => ({
  fetchRequestHandler: mocks.fetchRequestHandler,
}));

vi.mock("@acme/api", () => ({
  appRouter: mocks.appRouter,
  createTRPCContext: mocks.createTRPCContext,
}));

vi.mock("~/auth/server", () => ({
  auth: mocks.auth,
}));

import { GET, OPTIONS } from "./route";

describe("tRPC route handlers", () => {
  beforeEach(() => {
    mocks.fetchRequestHandler.mockClear();
    mocks.createTRPCContext.mockClear();
  });

  it("OPTIONS returns 204 and sets permissive CORS headers", () => {
    const response = OPTIONS();

    expect(response.status).toBe(204);
    expect(response.headers.get("Access-Control-Allow-Origin")).toBe("*");
    expect(response.headers.get("Access-Control-Request-Method")).toBe("*");
    expect(response.headers.get("Access-Control-Allow-Methods")).toBe(
      "OPTIONS, GET, POST",
    );
    expect(response.headers.get("Access-Control-Allow-Headers")).toBe("*");
  });

  it("GET delegates to fetchRequestHandler and reapplies CORS", async () => {
    const headers = new Headers({ "x-test": "1" });
    const request = { headers } as unknown as NextRequest;

    const result = await GET(request);

    expect(mocks.fetchRequestHandler).toHaveBeenCalledTimes(1);
    const args = mocks.fetchRequestHandler.mock.calls[0]?.[0];
    expect(args?.endpoint).toBe("/api/trpc");
    expect(args?.router).toBe(mocks.appRouter);
    expect(result.headers.get("Access-Control-Allow-Origin")).toBe("*");
    expect(result.headers.get("Access-Control-Allow-Methods")).toBe(
      "OPTIONS, GET, POST",
    );

    await args?.createContext();
    expect(mocks.createTRPCContext).toHaveBeenCalledWith({
      auth: mocks.auth,
      headers,
    });
  });
});
