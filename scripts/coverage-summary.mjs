#!/usr/bin/env node
/**
 * Aggregates Vitest/C8 coverage output into a compact summary file.
 *
 * Usage:
 *   node scripts/coverage-summary.mjs <input-json> <output-json>
 */
import { readFileSync, writeFileSync } from "node:fs";

const [inputPath, outputPath] = process.argv.slice(2);

if (!inputPath || !outputPath) {
  console.error("Usage: node scripts/coverage-summary.mjs <input-json> <output-json>");
  process.exit(1);
}

const coverage = JSON.parse(readFileSync(inputPath, "utf8"));

const totals = {
  lines: { covered: 0, total: 0 },
  branches: { covered: 0, total: 0 },
  functions: { covered: 0, total: 0 },
  statements: { covered: 0, total: 0 },
};

for (const file of Object.values(coverage)) {
  for (const key of Object.keys(totals)) {
    if (file[key]) {
      totals[key].covered += file[key].covered ?? 0;
      totals[key].total += file[key].total ?? 0;
    }
  }
}

const toPct = (covered, total) =>
  total === 0 ? 100 : Math.round((covered / total) * 10000) / 100;

const summary = {
  sha: process.env.GITHUB_SHA ?? null,
  branch: process.env.GITHUB_REF_NAME ?? null,
  generatedAt: new Date().toISOString(),
  totals: {
    lines: { ...totals.lines, pct: toPct(totals.lines.covered, totals.lines.total) },
    branches: {
      ...totals.branches,
      pct: toPct(totals.branches.covered, totals.branches.total),
    },
    functions: {
      ...totals.functions,
      pct: toPct(totals.functions.covered, totals.functions.total),
    },
    statements: {
      ...totals.statements,
      pct: toPct(totals.statements.covered, totals.statements.total),
    },
  },
};

writeFileSync(outputPath, JSON.stringify(summary, null, 2));

const formatted = [
  `lines: ${summary.totals.lines.pct}% (${totals.lines.covered}/${totals.lines.total})`,
  `branches: ${summary.totals.branches.pct}% (${totals.branches.covered}/${totals.branches.total})`,
  `functions: ${summary.totals.functions.pct}% (${totals.functions.covered}/${totals.functions.total})`,
  `statements: ${summary.totals.statements.pct}% (${totals.statements.covered}/${totals.statements.total})`,
].join("\n");

console.log(formatted);
