---
name: plan-github-issue
description: Analyze a GitHub issue and write an implementation plan into the issue itself — without implementing anything. Use this skill whenever the user invokes "/plan-github-issue", says "plan issue #N", "analyze this issue", "figure out how to approach issue N", or wants a solution designed and documented on a GitHub issue before any code is written. Not for actually fixing the issue (use fix-bug).
version: 1.0.0
---

# plan-github-issue

Analyze and plan a solution for the GitHub issue given as the skill argument (issue number or URL). Use the GitHub CLI (`gh`) for all GitHub-related tasks.

## Steps

1. Get the issue details: `gh issue view <n>` (add `--comments` — discussion often contains constraints the description lacks)
2. Understand the problem described in the issue
3. Search the codebase for relevant files; read enough to ground the plan in the actual code
4. Design a plan for the necessary changes: affected files, approach, risks, test strategy
5. **Do not implement the fix** — this skill ends at the plan
6. Update the issue description with the plan (`gh issue edit`), appending under a clearly marked plan section rather than overwriting the reporter's text
7. Label the issue:
   - `gh label list` to see available labels; apply relevant ones
   - Create new labels with `gh label create` only if genuinely necessary

Editing the issue publishes the plan — keep it professional and grounded; if anything about the issue is ambiguous, note open questions in the plan section instead of guessing silently.
