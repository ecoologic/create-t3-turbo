#!/bin/bash

# ATTENTION! Keep this script idempotent

# TODO: remove all version locks

echo "Git configuration..."
git remote add t3 https://github.com/t3-oss/create-t3-turbo.git
git config pull.rebase true
git config branch.autoSetupRebase always
echo "DONE"


echo "Git rebase from t3..."
git fetch t3 && git rebase -s recursive -X theirs t3/main
echo "DONE"

echo "Remove LICENSE."
rm LICENSE

echo "Node packages install..."
bash ./scripts/update-node.sh "$(jq -r '.engines.node' package.json | tr -d '^')"
corepack enable && corepack prepare pnpm@10.19.0 --activate # TODO: dynamic version of pnpm
echo "DONE"

echo "Ensuring workspace coverage dependencies..."
pnpm add -Dw istanbul-lib-coverage@^3.2.1
pnpm install
pnpm format:fix
pnpm lint:fix
echo "DONE"

echo "Setup DB."
pnpm db:push

echo "Setup Vitest and co..."
cd apps/nextjs || exit 1
pnpm add pg@^8.13.0
pnpm add -D \
  vitest@^4.0.7 \
  @vitejs/plugin-react@catalog \
  jsdom@^27.0.0 \
  @testing-library/react@^16.3.0 \
  @testing-library/dom@^10.4.1 \
  @testing-library/jest-dom@^6.6.3 \
  vite-tsconfig-paths@^5.1.4 \
  @vitest/coverage-v8@^4.0.8
pnpm pkg set 'scripts.specs=vitest'
cd ../..
echo "DONE"

echo "Testing..."
# pnpm specs || exit 2
./scripts/ci-local.sh
echo "DONE"
