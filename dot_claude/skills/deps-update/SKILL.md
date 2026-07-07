---
name: deps-update
description: Update project dependencies safely — list outdated packages, upgrade minors/patches in bulk and majors individually with changelog review, verify with build and tests, and commit in clean chore(deps) commits. Use this skill whenever the user says "update dependencies", "upgrade deps", "bump packages", "are my dependencies outdated", "update to the latest version of X", or mentions dependabot/renovate-style maintenance. Not for adding a brand-new dependency.
version: 1.0.0
---

# deps-update

Bring dependencies up to date without breaking the build, in commits that are easy to review and easy to revert individually.

## Process

### 1. Detect ecosystem(s) and survey

A repo may have several — check for all:

| Manifest | List outdated |
|---|---|
| `go.mod` | `go list -u -m all \| rg '\['` |
| `pyproject.toml` + `uv.lock` | `uv tree --outdated --depth 1` |
| `package.json` | `npm outdated` (or pnpm/yarn per lockfile) |

Show the user the outdated list grouped into **majors** vs **minors/patches** before changing anything, so scope is agreed. If everything is current, report that and stop.

### 2. Minors and patches — bulk

Semver-compatible upgrades in one pass:

- Go: `go get -u ./... && go mod tidy` — note Go treats majors as new import paths, so `-u` is already major-safe.
- uv: `uv lock --upgrade && uv sync`
- npm: `npm update`

Then verify: build + full test suite + linters (use the repo's own targets). If green, commit: `chore(deps): update minor and patch dependencies`.

### 3. Majors — one at a time

Each major individually, because each may need code changes and each should be revertable alone:

1. Check its changelog/release notes for breaking changes (GitHub releases page, `gh api repos/<owner>/<repo>/releases`, or Context7 for migration docs).
2. Upgrade just that package (`uv add pkg@latest`, `npm install pkg@latest`, Go: new `/vN` import path).
3. Apply any required code migrations.
4. Build + tests + linters. If it fails and the migration is more than mechanical, revert that upgrade, skip it, and record why.
5. Commit: `chore(deps)!: upgrade <pkg> to vN` (use `!` only when it changes this project's own public behavior; usually plain `chore(deps):`). Include a body noting required code changes.

### 4. Guardrails

- Never edit lockfiles by hand — always through the tool.
- Respect version pins/constraints in the manifest; if a pin blocks an update, report it rather than loosening it silently.
- Security advisories trump everything: if `npm audit` / `uv` / `govulncheck` flags a vulnerable dep, upgrade it even if it's a major, and say so prominently.
- Commit signing may need a TouchID approval; on SSH/agent signing errors, pause and ask the user to be present.
- Do not push.

### Report

Table of what was upgraded (from → to), what was skipped and why, verification results, and commits created.
