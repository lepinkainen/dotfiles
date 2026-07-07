---
name: write-tests
description: Write or extend automated tests for existing code — unit, integration, or regression — matching the project's test framework and conventions, then run them until green. Use this skill whenever the user says "write tests", "add tests", "test this", "add coverage", "this needs tests", names a file or function to test, or has just finished implementing something and wants it covered. Not for fixing bugs (use fix-bug) or running an app manually (use verify).
version: 1.0.0
---

# write-tests

Add meaningful automated tests for code the user points at (or the code just written in this session), in the project's existing style, and leave them passing.

## Process

### 1. Learn the local testing culture first

Before writing anything, find how this repo tests:

- Locate existing tests near the target code (`*_test.go`, `test_*.py`, `*.test.ts`, `tests/` dir).
- Read one or two of them fully. Match their framework, helpers, fixtures, naming, and assertion style — a test that looks foreign to the codebase will be rewritten or deleted by the next maintainer.
- Find the test command: Makefile/justfile targets, `CLAUDE.md`, CI config, or defaults (`go test ./...`, `uv run pytest`, `npm test`).

If the repo has no tests at all, pick the ecosystem default (Go stdlib `testing` with table-driven tests, `pytest`, `vitest`/built-in runner) and say so in the report.

### 2. Decide what deserves a test

Test behavior through the public surface, not implementation details — tests coupled to internals break on every refactor and protect nothing. Prioritize:

1. The happy path of each public function/endpoint under test
2. Error handling and edge inputs: empty, nil/None, zero, boundary values, malformed input
3. Anything with a conditional the user just wrote or changed

Don't chase coverage numbers. A handful of tests on the paths that can actually break beats exhaustive tests of trivial getters. Skip generated code and thin wrappers.

### 3. Write, run, iterate

- Write the tests, then run the test command for the affected package/module only (faster loop), then the full suite once at the end.
- Each new test must fail if the behavior it checks is broken. If unsure a test is actually asserting something, sabotage the expectation temporarily and confirm it fails, then restore.
- Keep tests deterministic: no sleeps for synchronization, no real network, no dependence on wall-clock or map ordering. Fake or inject time and I/O the way the existing tests do.

### 4. Never bend the code to the tests

If a test won't pass and investigation shows the *production code* is wrong, do not change the production code to make your test pass, and do not write the test to enshrine the buggy behavior. Stop and report the suspected bug to the user — fixing it is a separate decision (and the fix-bug skill's job).

The exception: small testability refactors (exporting a constructor arg, injecting a clock) are fine when they don't change behavior — mention them in the report.

### 5. Report

List: files created/modified, what each test covers in one line, the test command run, and the final pass/fail output. If any gaps were deliberately left (e.g. needs a live service), say so.
