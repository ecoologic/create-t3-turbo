# README

The common [README.md](../README.md]) is the default from [t3 create turbo app](https://github.com/t3-oss/create-t3-turbo.git). Our goal is to have a custom template but still be able to pull the changes from t3. So we decided to NOT make any change to the files in t3, but just add new folder/files for this template. So this file exist to explain how we use this custom template to kick off an initial project.

This README includes setup instructions, but it's _very_ good context to read the t3 README, so please go ahead and do that, knowing that we will help you setup a new project with the customised instructions below. Then come back here.

If any any point the documentation is outdated or needs improvement, _obviously_, it's your responsibility to update it as you go through it, but feel free to ask how to overcome the issues you can't resolve.

## Setup

```sh
./scripts/setup.sh

# Update .env
# Update packages/auth/script/auth-cli.ts
```

`./scripts/setup.sh` also installs [nektos/act](https://github.com/nektos/act) into `~/.local/bin`. Add `export PATH="$HOME/.local/bin:$PATH"` to your shell profile if that directory is not already on your `PATH`. You can rerun the installer on demand via `./scripts/install-act.sh`.

## Development

```sh
pnpm format:fix # Prettier
pnpm lint:fix # Eslint
```

## Local GitHub Actions via act

```sh
export ACT_IMAGE="catthehacker/ubuntu:act-latest"  # or put this in your shell profile
act pull_request \
  --workflows .github/workflows/ci-test.yaml \
  -P "ubuntu-latest=${ACT_IMAGE}"
```

Swap `-j lint` for other jobs:
- `typecheck` in `.github/workflows/ci.yml`
- `test` in `.github/workflows/ci-tests.yaml` (run `act pull_request --workflows .github/workflows/ci-tests.yaml ... -j test` to execute the test workflow)
Run both workflows by invoking `act` twice, once per workflow file.

Pass `--secret-file .github/act.secrets` (or your own path) when a workflow needs secrets or vars.

## Specs

* Colocate your specs with your production code
  * eg: `src/app/page.tsx` and `src/app/page.spec.tsx`
  * write _specs_ like: `it "renders stuff"` instead of `test("what")`

### Coverage reporting

- Configure min test percentage in apps/nextjs/vitest.config.ts and ci.yml
- CI now runs `pnpm -F @acme/nextjs specs --coverage` on every push/PR and pipes the Vitest V8 output through `scripts/coverage-summary.mjs` to generate a single `nextjs-coverage-summary.json`.
- Each run uploads an artifact named `nextjs-coverage-$SHA` that contains the raw Vitest reports plus the summary text file so you can download historical coverage per commit directly from the Actions UI.
- Successful main runs also upload a lightweight `nextjs-coverage-summary` artifact; pull requests automatically fetch the most recent one from `main`, compare the line/branch/function/statement percentages, and display the delta in the job summary.
- The summary step prefers Vitest's `coverage-summary.json`, but if that file isn't available it consumes `coverage-final.json`; if neither exists the workflow fails so missing coverage can't slip through unnoticed.
- The pipeline fails if line coverage dips below 10%, so keep at least one real test in place before opening a PR.
- If no successful `main` run exists yet the compare step is skipped, but artifacts are still created so the next run has a baseline.
- You can inspect the coverage totals/deltas inside the `CI / test` job summary and, if needed, download the summary artifact to feed into other tooling.

OK: pg broken
OK: GHA
OK: act
TODO: enforce specs with eslint
TODO: wider linting airbnb etc
TODO: dbcleaner and factories?
TODO: Husky pre-commit
TODO: Mongo
TODO: Trunk?
TODO: Cypress

### Resources

* https://vitest.dev/api/expect.html
* https://www.betterspecs.org - it's Ruby, but it's clear and simple

## Good dev

* Boyscout rule: leave things better than you found them (including this setup)
* Tests: if you fix a bug, you need to add testing, bugs tend to show up in the same logic

---

## Postgres

```sql
psql -U postgres -d postgres
create database acme1;
CREATE ROLE acme WITH LOGIN PASSWORD 'acmeacme1';
GRANT ALL PRIVILEGES ON DATABASE acme1 TO acme;
```

## Easy contributions

* packages/db/drizzle.config.ts `camelCase`??
* black 500 error

## WFT??

* Broken out of the box (see contributions)
* No tests setup?? no wonder it's broken
* DB tables in the package folder? setup for chaos BE logic duplication
* Instructions to setup the DB in the postgres DB, dirty dangerous
* `/script/` singular? folders should be plural
* White page 500 error, annoying
* No docker?
