---
description: Check code health
---

Audit this codebase for health issues: large files/modules, duplicated logic, dead/legacy code or unused params, test coverage gaps, and documentation/config drift. Read the repo and include current working tree changes. Identify candidates by size (e.g., 400+ LOC), repeated blocks, unreferenced functions/flags, and stale docs. Map tests to modules and highlight missing coverage for critical paths (CLI flags, error handling, integrations). Compare README/docs/config with actual behavior.

Output findings ordered by severity with file path + line number, brief evidence, and impact. Then list coverage gaps and doc/config mismatches. If none, say so and mention residual risks.
