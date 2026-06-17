---
name: whereami
description: This skill should be used when the user invokes "/whereami" or asks "where am I", "what's the state of this repo", "what was I working on", "remind me what this project is", or wants a quick project-state recap. Summarizes purpose, git state, recent commits, and likely next step.
version: 1.0.0
---

# whereami

Summarize current project state for the user. Delegate to a Sonnet subagent to keep main-loop context clean and to run analysis on a cheaper model.

## How to run

Spawn one Agent via the Agent tool with these arguments:

- `subagent_type`: `general-purpose`
- `model`: `sonnet`
- `description`: `Project state recap`
- `prompt`: instruct the agent to gather and report the items below, running from the user's current working directory.

Items the agent must gather:

- Project purpose and goal — read `README.md` and `CLAUDE.md` if present.
- Git repo status — current branch, last commit (hash + subject + relative date).
- Uncommitted changes — `git status -s` plus short diffstat.
- Recent history — `git log --oneline -5`.
- Active direction inferred from recent commits.

Instruct the agent to return a terse markdown report under 200 words with sections: **Project**, **State**, **Recent**, **Next**.

## Output

Relay the agent's report verbatim. No preamble, no trailing summary.
