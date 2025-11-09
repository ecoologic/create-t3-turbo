export type BaseUrlEnv = {
  VERCEL_ENV?: string | null;
  VERCEL_PROJECT_PRODUCTION_URL?: string | null;
  VERCEL_URL?: string | null;
};

export const resolveBaseUrl = (runtimeEnv: BaseUrlEnv) => {
  if (runtimeEnv.VERCEL_ENV === "production") {
    return `https://${runtimeEnv.VERCEL_PROJECT_PRODUCTION_URL ?? ""}`;
  }
  if (runtimeEnv.VERCEL_ENV === "preview") {
    return `https://${runtimeEnv.VERCEL_URL ?? ""}`;
  }
  return "http://localhost:3000";
};
