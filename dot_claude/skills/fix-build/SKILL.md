---
name: fix-build
description: Get a failing build back to green — run the project's build, test, and lint commands, then fix every reported compile error, test failure, and lint violation until all pass. Use this skill whenever the user invokes "/fix-build", says "the build is broken", "fix the build", "it doesn't compile", "CI is red", "make the tests pass", or pastes build/compiler errors asking for them to be resolved.
version: 1.0.0
---

# fix-build

The build is failing. Run the build and fix each of the reported build, test, and linter errors. Done only when everything completes without errors.

## Process

1. Find the repo's real commands: Makefile/justfile targets, CI config, `CLAUDE.md`, or ecosystem defaults (`go build ./... && go test ./... && go vet ./...`, `uv run pytest` + linter, `npm run build && npm test`).
2. Run them and collect **all** errors before fixing — errors often share one root cause (a changed signature, a missing import); fixing the root beats whack-a-mole on each symptom.
3. Fix, re-run, repeat. Prefer the smallest change that restores correctness.
4. Do not silence errors to get to green: no deleting failing tests, no `//nolint` / `# type: ignore` / `@ts-ignore` blankets, no loosening compiler or linter config. If a test fails because the *test* is genuinely outdated relative to intended behavior, updating it is fine — say so in the report. If intended behavior is unclear, stop and ask.
5. Done when build, tests, and linters all pass. Report what was broken, the root cause(s), and what changed.
