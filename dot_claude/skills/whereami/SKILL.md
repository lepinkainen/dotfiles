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
- Claude memory — derive the project dir by replacing every `/` in the cwd with `-` (e.g. `/Users/x/proj` → `-Users-x-proj`), then read `~/.claude/projects/<encoded-cwd>/memory/MEMORY.md` and any `memory/*.md` files if present. Summarize relevant project/feedback facts.
- Recent chat log — list `~/.claude/projects/<encoded-cwd>/*.jsonl` (the session transcripts), pick the most recently modified one or two, and skim the tail for what was last being worked on. These are large; read only the final lines and extract the latest user intent and unfinished work.

Instruct the agent to return a terse markdown report under 250 words with sections: **Project**, **State**, **Recent**, **Memory**, **Next**. Omit **Memory** if no memory files or transcripts exist.

## Output

Relay the agent's report verbatim. No preamble, no trailing summary.
