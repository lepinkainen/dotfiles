---
name: fix-bug
description: Diagnose and fix a bug or GitHub issue with test-backed verification — reproduce, root-cause, fix, and guard with a red-green or regression test so it can't silently return. Use this skill whenever the user says "fix this bug", "there's a bug in", "this is broken", "fix issue #N", pastes a stack trace or error output and wants it fixed, or describes wrong behavior ("returns the wrong value", "crashes when"). Not for build/compile failures (use fix-build) or writing tests for working code (use write-tests).
version: 1.0.0
---

# fix-bug

Fix a bug so it stays fixed. Every bugfix ships with a test that fails without the fix — otherwise the same bug can come back in six months with nothing to catch it. That test requirement is non-negotiable; how it's sequenced (red-green vs. after-the-fix) is flexible.

## Process

### 1. Understand the bug

- If given a GitHub issue reference (`#123`, an issue URL, or an argument to the skill): `gh issue view <n>` for the description, repro steps, and comments.
- Otherwise work from the user's description, pasted stack trace, or failing output.
- Search the codebase for the involved code paths. Read enough surrounding code to explain the *mechanism* of the bug, not just its location. "This line is wrong" without knowing why it's wrong leads to fixes that break something else.

### 2. Reproduce

Confirm the bug actually occurs before changing anything — run the failing case, hit the endpoint, run the snippet. A bug that can't be reproduced can't be verified fixed; if reproduction genuinely isn't possible (race condition, environment-specific), say so and reason from the code, but flag the lower confidence in the report.

### 3. Test-backed fix — pick one of two sequences

**Preferred — red-green:** write the test *first*.

1. Write a test that captures the correct behavior. Run it — it must **fail, for the right reason** (the bug's symptom, not a typo in the test).
2. Apply the smallest fix that addresses the root cause.
3. Run the test — green. Run the surrounding suite — still green.

Red-first is preferred because it proves the test actually detects the bug; a test written after the fix might pass vacuously.

**Fallback — regression test after the fix:** when red-first is impractical (fix needed to even understand correct behavior, or test scaffolding must be built around the fixed code), fix first, then add the regression test. Then **prove the test guards the fix**: temporarily revert the fix (`git stash` the fix hunks or invert the change), run the test, confirm it fails, restore the fix. A regression test that passes both with and without the fix is decoration, not protection.

Either way: match the repo's existing test conventions (see neighboring test files), and never weaken an existing test to make the fix pass — a newly-failing existing test means the fix is wrong or the old test enshrined the bug; investigate and report which.

### 4. Verify the whole

The fix is done only when build, full test suite, linting, and type checking all pass. Run whatever this repo uses (Makefile/justfile targets, CI config, `go build ./... && go vet ./...`, `uv run pytest`, etc.).

### 5. Deliver

**Local bug (no issue):** commit fix + test together as one atomic commit (`fix(<scope>): <what>` with a body explaining the root cause). Stop there — do not push.

**GitHub issue:** follow the full flow:

1. Branch off the default branch: `git checkout -b fix/<issue-number>-<slug>`
2. Commit fix + test (`fix(<scope>): <subject>`, body references root cause, footer `Fixes #<n>`)
3. Push the branch and open a PR linked to the issue: `gh pr create --title "..." --body "... Fixes #<n>"`

Commit signing may require the user to approve a TouchID prompt. On an SSH/agent signing error, stop and ask the user to be present — do not retry blindly or disable signing.

### Report

State: root cause (mechanism, one or two sentences), the fix, the guarding test and *proof it guards* (red-then-green, or revert-check result), and verification output. If confidence is reduced (couldn't reproduce, couldn't revert-check), say so explicitly.
