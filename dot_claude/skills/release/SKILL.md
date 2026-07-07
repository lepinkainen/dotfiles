---
name: release
description: Cut a release from Conventional Commits history — generate or update the changelog, decide the semver bump, update version files, and create an annotated git tag. Use this skill whenever the user says "cut a release", "make a release", "prepare a release", "bump the version", "tag a version", "update the changelog", or asks "what should the next version be". Also use it when the user names a specific version to release ("release v1.4.0").
version: 1.0.0
---

# release

Turn the Conventional Commits history since the last tag into a changelog entry, a version bump, and an annotated tag. Commits are the source of truth — the whole point of enforcing Conventional Commits is that releases can be derived mechanically from them.

## Process

### 1. Establish the range

```bash
git describe --tags --abbrev=0        # last tag (may fail: first release)
git --no-pager log <last-tag>..HEAD --oneline
git status --short                    # tree must be clean before releasing
```

If the working tree is dirty, stop and tell the user — a release must be cut from committed state. If there are no commits since the last tag, report that and stop.

### 2. Decide the bump

Classify the commits in the range:

- Any `!` suffix or `BREAKING CHANGE:` footer → **major**
- Else any `feat` → **minor**
- Else any `fix` / `perf` → **patch**
- Only `docs` / `chore` / `ci` / `test` / `style` / `refactor` → ask the user whether a release is warranted at all; if yes, patch.

Pre-1.0 exception: while the project is `0.x`, breaking changes bump minor and everything else bumps patch, unless the user says otherwise. If the user named a version explicitly, use theirs — but warn if it contradicts the commit history (e.g. they asked for a patch but there are breaking changes).

### 3. Write the changelog

Use the existing changelog format if `CHANGELOG.md` exists — match its style exactly. If the repo uses a generator (`cliff.toml` → `git-cliff`, `.chglog/` → `git-chglog`), run the tool instead of writing by hand.

Otherwise create/update `CHANGELOG.md` in Keep a Changelog style:

```markdown
## [1.4.0] - 2026-07-07

### Added
- pagination on search endpoint (api)

### Fixed
- connection pool exhaustion under load (db)
```

Map types: `feat` → Added, `fix` → Fixed, `perf` → Changed (performance), breaking → its own **Breaking changes** section at the top. Skip `chore`/`ci`/`test` noise unless user-visible. Write entries for humans reading release notes — expand terse commit subjects when the diff makes the impact clearer, don't just paste subjects verbatim.

### 4. Update version files

Only touch files that actually carry a version in this repo:

- Python: `version` in `pyproject.toml`
- Node: `version` in `package.json` (use `npm version --no-git-tag-version <ver>` to keep lockfile in sync)
- Go: usually tag-only, no file to edit — but check for a hardcoded `version` const/var (`rg -i 'version\s*=\s*"[0-9]'`)
- Anything else the repo's release docs mention

### 5. Commit and tag

```bash
git add CHANGELOG.md <version files>
git commit -m "chore(release): v<version>"
git tag -a v<version> -m "v<version>"
```

Commit and tag signing may require the user to approve a TouchID prompt. If signing fails with an SSH/agent error, stop and ask the user to be present, then retry — do not disable signing.

### 6. Report — do not push

Show the user: new version, tag name, changelog entry. **Never push the tag or the commit without being asked** — pushing a tag typically triggers CI release pipelines and publishing, which is not reversible. Offer the exact push command instead:

```bash
git push origin main --follow-tags
```
