#!/usr/bin/env bash
set -euo pipefail

node - <<'NODE'
const min = Number(process.env.MIN_LINES_COVERAGE_PERCENT);
const lines = Number(process.env.LINES_PCT ?? 0);
if (Number.isNaN(lines)) {
  console.error("Unable to parse lines coverage percentage.");
  process.exit(1);
}
if (lines < min) {
  console.error(`Coverage check failed: lines ${lines}% < minimum ${min}%.`);
  process.exit(1);
}
console.log(`Coverage check passed: lines ${lines}% >= minimum ${min}%.`);
NODE
