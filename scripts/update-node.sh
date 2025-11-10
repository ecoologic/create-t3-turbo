#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $(basename "$0") <major.minor.patch>" >&2
  exit 1
fi

NEW_VERSION="$1"

if [[ ! $NEW_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "error: version must be in the form major.minor.patch (got '$NEW_VERSION')" >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Updating Node version to $NEW_VERSION"

# Update .nvmrc
printf '%s\n' "$NEW_VERSION" >"$REPO_ROOT/.nvmrc"

# Update package.json engines.node while preserving formatting
REPO_ROOT="$REPO_ROOT" VERSION="$NEW_VERSION" node <<'NODE'
const fs = require('fs');
const path = require('path');

const repoRoot = process.env.REPO_ROOT;
const version = process.env.VERSION;
const pkgPath = path.join(repoRoot, 'package.json');

const pkgRaw = fs.readFileSync(pkgPath, 'utf8');
const pkg = JSON.parse(pkgRaw);
pkg.engines = pkg.engines || {};
pkg.engines.node = `^${version}`;

fs.writeFileSync(pkgPath, JSON.stringify(pkg, null, 2) + '\n');
NODE

# Update Trunk runtime pin
REPO_ROOT="$REPO_ROOT" VERSION="$NEW_VERSION" node <<'NODE'
const fs = require('fs');
const path = require('path');

const repoRoot = process.env.REPO_ROOT;
const version = process.env.VERSION;
const trunkPath = path.join(repoRoot, '.trunk', 'trunk.yaml');

const before = fs.readFileSync(trunkPath, 'utf8');
const runtimePattern = /node@[0-9]+\.[0-9]+\.[0-9]+/;
let after = before;

if (runtimePattern.test(before)) {
  after = before.replace(runtimePattern, `node@${version}`);
} else {
  // Insert the node runtime entry if it's missing entirely.
  const lines = before.split('\n');
  const runtimeBlockStart = lines.findIndex((line) => line.trim() === 'runtimes:');
  if (runtimeBlockStart === -1) {
    console.error('error: could not find runtimes section in .trunk/trunk.yaml');
    process.exit(1);
  }

  let enabledIndex = -1;
  for (let i = runtimeBlockStart + 1; i < lines.length; i += 1) {
    const line = lines[i];
    const trimmed = line.trim();
    if (!line.startsWith('  ') && trimmed.length) {
      break; // exited runtimes block without finding enabled list
    }
    if (trimmed === 'enabled:') {
      enabledIndex = i;
      break;
    }
  }

  if (enabledIndex === -1) {
    console.error('error: could not find runtimes.enabled list in .trunk/trunk.yaml');
    process.exit(1);
  }

  let insertIndex = enabledIndex + 1;
  while (insertIndex < lines.length && lines[insertIndex].startsWith('    -')) {
    insertIndex += 1;
  }

  lines.splice(insertIndex, 0, `    - node@${version}`);
  after = `${lines.join('\n')}\n`;
}

if (!after.includes(`node@${version}`)) {
  console.error('error: failed to update node runtime in .trunk/trunk.yaml');
  process.exit(1);
}

if (after !== before) {
  fs.writeFileSync(trunkPath, after);
}
NODE

echo "Updated .nvmrc, package.json, and .trunk/trunk.yaml"
