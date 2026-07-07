---
name: check-code-health
description: Audit a codebase for health issues — oversized files, duplicated logic, dead code, unused parameters, test coverage gaps, and documentation/config drift — and report findings ordered by severity. Use this skill whenever the user invokes "/check-code-health", asks about "code health", "tech debt", "code quality audit", "find dead code", "what needs cleanup", or wants a maintenance overview of the repo.
version: 1.0.0
---

# check-code-health

Audit this codebase for health issues: large files/modules, duplicated logic, dead/legacy code or unused params, test coverage gaps, and documentation/config drift. Read the repo and include current working tree changes.

## What to look for

- **Size**: candidates at 400+ LOC per file/module — flag where splitting would help, not mechanically.
- **Duplication**: repeated blocks or near-identical functions across files.
- **Dead code**: unreferenced functions, unused flags/params, legacy paths kept "just in case".
- **Coverage gaps**: map tests to modules; highlight missing coverage for critical paths (CLI flags, error handling, integrations).
- **Drift**: compare README/docs/config with actual behavior — commands that no longer exist, options that changed defaults, undocumented features.

## Output

Findings ordered by severity, each with file path + line number, brief evidence, and impact. Then list coverage gaps and doc/config mismatches separately. If a category is clean, say so and mention residual risks.

Report only — do not fix anything unless the user asks. Fixes route to the right skill afterwards (write-tests for coverage gaps, simplify for duplication).
