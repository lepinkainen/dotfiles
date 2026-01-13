---
description: Create atomic git commits using conventional commits.
---

# Commit

Create atomic git commits using conventional commits.

## Constraints (Non-Interactive)

This prompt runs unattended (e.g. from a detached tmux session).

- Use only non-interactive commands.
- Never open an editor or pager.
- Do not run `git push`.

## Process

- Inspect current changes with `git status` and `git --no-pager diff HEAD`.
- Decide whether the changes should be one commit or several logical commits.
- If multiple logical changes exist, plan and split them into separate commits.
- For each commit:
  - Stage only the relevant changes with `git add ...`.
  - Review the staged diff (e.g. `git --no-pager diff --cached`) to confirm what's included.
  - Commit with a message (`git commit -m "…"`) following the style below.
- After all commits are made:
  - Pull latest changes: `git pull --rebase`
  - If conflicts occur, resolve them and continue the rebase with `git rebase --continue`
- Return the commits to the user.

## Style

- **Atomic**: One concern per commit.
- **Split big changes**: Separate features, fixes, refactors, docs, etc. when they are independent.
- **Subject line**:
  - Format: `<type>[optional scope]: <description>`
  - Format with breaking change: Add ! after type/scope (before the colon)
  - Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`, `ci`, `build`, `revert`
  - Scopes are optional but recommended for larger codebases
  - Use parentheses for scope: `feat(auth):`, `fix(api):`, `refactor(parser):`
  - Scope should identify the module, component, or area affected
  - Common scopes: `auth`, `api`, `cli`, `parser`, `ui`, `db`, `config`
  - Imperative, present tense (e.g. "add…", "fix…").
  - Under 72 characters.
  - No trailing period.
- Always ensure the commit message accurately reflects the diff.

## Breaking Changes

Use breaking change notation when introducing changes that break backward compatibility:

- **Exclamation mark**: Add ! after the type/scope, example: feat(api)! remove deprecated endpoints
- **Footer**: Or add `BREAKING CHANGE:` footer in the commit body
- **When to use**: API changes, removed features, behavior changes requiring user action
- **Example**:
  ```
  feat!: change configuration format from JSON to YAML

  BREAKING CHANGE: Configuration files must be migrated from .json to .yaml format.
  Use the provided migration script: ./scripts/migrate-config.sh
  ```

## Type Definitions

- `feat`: New feature for the user (not internal tooling)
- `fix`: Bug fix for the user (not internal tooling)
- `docs`: Documentation only changes (README, comments, docs/)
- `style`: Code style changes (formatting, missing semicolons, whitespace)
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `test`: Adding missing tests or correcting existing tests
- `chore`: Changes to build process, dependencies, or tooling
- `perf`: Performance improvements
- `ci`: CI/CD configuration changes
- `build`: Changes affecting build system or dependencies
- `revert`: Reverts a previous commit

## Commit Body

The commit body is optional for simple changes but recommended when the commit needs explanation beyond the subject line:

- Separate subject from body with a blank line
- Wrap body at 72 characters
- Explain the "why" not the "what" (the code shows what changed)
- Include context, motivation, reasoning, or side effects
- **Example**:
  ```
  fix: prevent race condition in cache updates

  The cache was being updated from multiple goroutines without
  proper synchronization, causing intermittent data corruption
  under high load. Added mutex locks around all cache write
  operations to ensure thread safety.

  Fixes #1234
  ```

## Splitting Commits

Split into multiple commits when:

- Changes touch unrelated parts of the codebase.
- Different types of work are mixed (feature, fix, refactor, docs, tests, chore).
- Different file types are mixed in a way that’s easier to review separately (e.g. code vs docs).
- The diff is very large and can be broken into smaller, easier-to-review steps.

## Command Examples

### Scenario 1: Single atomic commit
```bash
git status
git --no-pager diff HEAD
git add .
git --no-pager diff --cached
git commit -m "feat: add user authentication system"
```

### Scenario 2: Splitting into multiple commits
```bash
# Check all changes
git status
git --no-pager diff HEAD

# First commit: feature
git add src/auth/
git commit -m "feat(auth): add login endpoint"

# Second commit: tests
git add tests/auth/
git commit -m "test(auth): add login endpoint tests"

# Third commit: docs
git add README.md docs/
git commit -m "docs: document authentication flow"
```

### Scenario 3: Partial file staging
```bash
# Stage specific files only
git add src/parser/tokenizer.go src/parser/parser.go
git commit -m "refactor(parser): simplify token handling"

# Stage remaining changes separately
git add .
git commit -m "chore: update dependencies"
```

## Common Mistakes to Avoid

- ❌ Mixing multiple changes in one commit
- ❌ Vague messages: `fix: fix bug`, `chore: update stuff`
- ❌ Using past tense: `fixed` instead of `fix`
- ❌ Adding periods at end of subject line
- ❌ Subject line over 72 characters
- ❌ Missing type prefix
- ❌ Using `feat` for internal tooling (should be `chore`)
- ❌ Not explaining breaking changes
- ❌ Committing unrelated formatting changes with features

## Examples

### Basic commits
- feat: add user authentication system
- fix: resolve memory leak in rendering process
- docs: update API documentation with new endpoints
- refactor: simplify error handling logic in parser
- style: reorganize component structure for better readability
- chore: remove deprecated legacy code
- ci: resolve failing CI pipeline tests

### Commits with scopes
- feat(api): add pagination to search endpoint
- feat(auth): implement OAuth2 login flow
- fix(db): prevent connection pool exhaustion
- fix(parser): handle edge case with nested brackets
- docs(readme): add installation instructions
- test(api): add integration tests for webhooks
- chore(deps): update dependencies to latest versions
- perf(db): add index on frequently queried columns

### Breaking changes
- feat(auth)!: remove support for OAuth 1.0
- feat!: change configuration format from JSON to YAML
- refactor(api)!: restructure endpoint paths
