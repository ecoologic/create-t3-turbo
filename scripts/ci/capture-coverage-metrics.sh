#!/usr/bin/env bash
set -euo pipefail

node - <<'NODE'
const fs = require("fs");
const summaryPath = process.env.SUMMARY_PATH;
if (!summaryPath) {
  console.error("SUMMARY_PATH env var is required.");
  process.exit(1);
}
const summary = JSON.parse(fs.readFileSync(summaryPath, "utf8"));
const round = (value) => Math.round(value * 100) / 100;
const append = (k, v) => fs.appendFileSync(process.env.GITHUB_OUTPUT, `${k}=${round(v)}\n`);
append("lines_pct", summary.totals.lines.pct);
append("branches_pct", summary.totals.branches.pct);
append("functions_pct", summary.totals.functions.pct);
append("statements_pct", summary.totals.statements.pct);
NODE
