#!/usr/bin/env bash
set -euo pipefail

if [ -z "${CURRENT_SUMMARY:-}" ]; then
  echo "CURRENT_SUMMARY env var is required." >&2
  exit 1
fi
BASELINE_SUMMARY=$(find tmp/baseline-coverage -name "nextjs-coverage-summary.json" -print -quit)
if [ -z "$BASELINE_SUMMARY" ]; then
  echo "Unable to locate baseline coverage summary file." >&2
  exit 1
fi
export BASELINE_SUMMARY
node - <<'NODE'
const fs = require("fs");
const current = JSON.parse(fs.readFileSync(process.env.CURRENT_SUMMARY, "utf8"));
const baseline = JSON.parse(fs.readFileSync(process.env.BASELINE_SUMMARY, "utf8"));
const round = (value) => Math.round(value * 100) / 100;
const setOutput = (name, value) => fs.appendFileSync(process.env.GITHUB_OUTPUT, `${name}=${value}\n`);
const metrics = ["lines", "branches", "functions", "statements"];
const lines = metrics.map((metric) => {
  const currentPct = round(current.totals[metric].pct);
  const baselinePct = round(baseline.totals[metric].pct);
  const diff = round(currentPct - baselinePct);
  setOutput(`baseline_${metric}_pct`, baselinePct);
  setOutput(`${metric}_diff`, diff);
  return `- ${metric[0].toUpperCase() + metric.slice(1)}: ${currentPct}% (Δ ${diff} vs ${baselinePct}%)`;
});
fs.appendFileSync(process.env.GITHUB_STEP_SUMMARY, `\n### Coverage delta vs main\n${lines.join("\n")}\n`);
NODE
