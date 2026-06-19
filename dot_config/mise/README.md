# mise config

`config.toml.tmpl` is the global mise config, rendered per-OS by chezmoi to
`~/.config/mise/config.toml`.

## Ownership

| Concern | Owner |
|---|---|
| Versioned dev runtimes (`[tools]`) | mise — separate install dir, per-project version switching |
| System CLI **formulae** (`[bootstrap.packages]`) | mise orchestrates, but they land in brew (`/opt/homebrew`) |
| Homebrew **casks** (GUI apps, fonts) | Brewfile / chezmoi `run_onchange` — mise's brew backend can't do casks |
| dotfiles, secrets (age) | chezmoi |
| per-project env | direnv (kept minimal) |

## Apply / use (manual for now)

```sh
chezmoi apply                 # render config.toml.tmpl -> ~/.config/mise/config.toml
mise bootstrap                # install [tools] + [bootstrap.packages], run defaults/tasks
```

Not yet wired into `run_onchange_install-packages.sh` — that stays brew-bundle
based until the mise flow is trusted. `mise bootstrap` is experimental in
2026.6.x, hence `[settings] experimental = true`.

### Validate edits before applying

```sh
chezmoi execute-template < ~/projects/dotfiles/dot_config/mise/config.toml.tmpl > /tmp/m.toml
mise trust /tmp/m.toml && mise bootstrap packages status -C /tmp
```

## go: why it lives in brew, not mise (Path A)

`go` is currently a `brew:` formula, NOT a mise `[tool]`. Reason: the go-tooling
formulae (`gofumpt`, `golangci-lint`, `gopls`, `goimports`, `go-task`, `go-air`)
declare brew's `go` as a dependency, so `brew uninstall go` is refused while they
exist. Keeping go in brew keeps that stack coherent.

Tradeoff: no per-project Go version switching. Acceptable for now.

## Path B — move go fully to mise (future)

When per-project Go versions are wanted, move the go tools off brew too (mise
installs them as prebuilt binaries via aqua/ubi/go backends — no go compiler
needed for the aqua/ubi ones):

```toml
[tools]
go = "latest"
"aqua:mvdan/gofumpt" = "latest"
"aqua:golangci/golangci-lint" = "latest"
"aqua:go-task/task" = "latest"
"aqua:air-verse/air" = "latest"
"go:golang.org/x/tools/gopls" = "latest"
"go:golang.org/x/tools/cmd/goimports" = "latest"
```

Then remove the corresponding `brew:` lines and uninstall the brew copies:

```sh
brew uninstall go-air gofumpt golangci-lint gopls goimports go-task go
```

Verify each `aqua:`/`go:` name resolves with `mise bootstrap packages status`
(or `mise ls-remote <tool>`) before committing.
