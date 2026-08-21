---
name: pr-vs-code-comments
description: Decide whether an explanation belongs in the PR title/description or in a code comment, based on Raymond Chen's point-in-time vs durable rule. Use this skill whenever writing or reviewing a pull request title or description, whenever deciding whether to add a code comment, and whenever reviewing a diff that adds comments — even if the user only says "open a PR", "write the PR description", "should I comment this", or "clean up these comments".
---

# PR descriptions vs code comments

Two places explain a change: the pull request and the code. They serve different
readers at different times. Putting information in the wrong place makes it either
misleading later or invisible when needed.

## The core rule

- **PR description = point-in-time persuasion.** It justifies the change to the
  reviewer, at review time. Once merged, nobody guarantees its claims stay true.
- **Code comment = durable information.** It explains the code to every future
  reader. It must remain true until the code itself changes, and it must make sense
  to someone who never saw the PR.

Litmus test for any sentence you're about to write: *would this still be true and
useful a year from now, to a reader who never saw the PR?*

- Yes → code comment.
- No (it's about why the change is needed now, how it was validated, what
  alternatives were rejected) → PR description.

## PR titles

Write titles for the engineer hunting a regression six weeks later, skimming the
merge log. Name the specific component, not just the behavior:

- Weak: `Fix crash when polarity changes`
- Strong: `Fix widget crash when polarity changes twice in a short time`

The extra specificity lets a reader who works on gadgets skip the PR entirely, and
lets a reader who consumes widgets know to dig in. A vague title forces everyone to
open the PR to find out it's irrelevant.

## PR descriptions

The description is persuasive writing aimed at the approver. Include:

- The source of the problem and how the change fixes it.
- How you validated it (tests run, before/after screenshots, manual checks).
- Alternatives considered and why they were rejected (too risky, too broad).
- Scope claims like "I checked all callers; this was the only one passing the
  wrong flag." These are true only at review time — they belong here, never in
  the code, because a caller added next month invalidates them silently.

## Code comments

Comments describe the code itself: how to call a function correctly, its
prerequisites, the schema it accepts, the invariant it maintains.

Two traps:

1. **Future tense about other components.** "The Doodad component will take
   advantage of this" is a PR-description fact — the other team won't update your
   comment when their plans change, and the comment wrongly implies the feature is
   safe to delete once Doodad stops needing it. If provenance is worth recording,
   state it as history: `// Polarity reversal was initially added for the benefit
   of the Doodad component.`

2. **Comments that only make sense with the PR open.** A comment must carry its
   own context. And put migration notes where the action happens: write
   `// When all clients have migrated to the new function, delete this function.`
   on the **old** function — not "keep this" on the new one, which reads as an
   instruction to do nothing.

## Sorting exercise

| Statement | Where | Why |
|---|---|---|
| "I checked all calls; only this one passed the wrong flag." | PR description | True only at review time. |
| "The JSON schema accepted by this function is documented here: <link>." | Code comment | Useful until the function or schema changes. |
| "The Doodad component will take advantage of polarity reversal." | PR description | Other team's future plans; goes stale silently. |
| "Polarity reversal was initially added for the Doodad component." | Code comment | Historical fact; stays true forever. |

Source: Raymond Chen, *The Old New Thing*, "The difference between a pull request
description and a code comment" (2026-08-12),
https://devblogs.microsoft.com/oldnewthing/20260812-00/?p=112607
