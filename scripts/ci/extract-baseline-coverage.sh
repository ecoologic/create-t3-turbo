#!/usr/bin/env bash
set -euo pipefail

zip_path="${BASELINE_COVERAGE_ZIP:-}"
if [ -z "$zip_path" ]; then
  echo "BASELINE_COVERAGE_ZIP env var is required." >&2
  exit 1
fi
rm -rf tmp/baseline-coverage
mkdir -p tmp/baseline-coverage
unzip -q "$zip_path" -d tmp/baseline-coverage
