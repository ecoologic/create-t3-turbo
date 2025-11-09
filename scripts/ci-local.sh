#!/usr/bin/env bash
set -euo pipefail

# TODO: use https://github.com/nektos/act

# Mirror the checks that run in .github/workflows/ci.yml.
pnpm lint
pnpm lint:ws
pnpm format
pnpm typecheck
pnpm --filter @acme/nextjs vitest run --coverage
pnpm build
