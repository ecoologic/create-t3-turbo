#!/usr/bin/env bash
set -euo pipefail

mkdir -p tmp
INPUT_PATH=""
if [ -f apps/nextjs/coverage/coverage-summary.json ]; then
  INPUT_PATH="apps/nextjs/coverage/coverage-summary.json"
elif [ -f apps/nextjs/coverage/coverage-final.json ]; then
  INPUT_PATH="apps/nextjs/coverage/coverage-final.json"
else
  echo "Expected coverage summary JSON but none was produced." >&2
  echo "Ensure 'pnpm -F @acme/nextjs specs --coverage' writes to apps/nextjs/coverage/." >&2
  exit 1
fi
node scripts/coverage-summary.mjs "$INPUT_PATH" tmp/nextjs-coverage-summary.json | tee tmp/nextjs-coverage-summary.txt
