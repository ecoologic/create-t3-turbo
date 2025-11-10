#!/usr/bin/env bash
set -euo pipefail

{
  echo "### Next.js coverage";
  cat tmp/nextjs-coverage-summary.txt;
} >> "$GITHUB_STEP_SUMMARY"
