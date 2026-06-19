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

## go and node: why they live in brew, not mise (Path A)

`go` and `node` are `brew:` formulae, NOT mise `[tools]`. Reason: other brew
formulae declare them as dependencies, so `brew uninstall` is refused while
those exist:

- **go** ← `gofumpt`, `golangci-lint`, `gopls`, `goimports`, `go-task`, `go-air`
- **node** ← `gemini-cli`, `opencode`, `typescript`, `typescript-language-server`,
  `vscode-langservers-extracted`

Keeping the runtime in brew keeps each stack coherent. `[tools]` is empty for now.

Tradeoff: no per-project version switching for go/node. Acceptable for now.

## Path B — move a runtime fully to mise (future)

To get per-project versions of a runtime, move the dependent tools off brew too,
then the runtime into mise `[tools]`. mise installs the tools as prebuilt
binaries via aqua/ubi backends (no compiler needed) or the language backend.

### go

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

```sh
brew uninstall go-air gofumpt golangci-lint gopls goimports go-task go
```

### node

```toml
[tools]
node = "lts"
"npm:typescript" = "latest"
"npm:typescript-language-server" = "latest"
"npm:vscode-langservers-extracted" = "latest"
# gemini-cli / opencode: install via npm: or their own backends
```

```sh
brew uninstall gemini-cli opencode typescript typescript-language-server vscode-langservers-extracted node
```

Verify each `aqua:`/`go:`/`npm:` name resolves with
`mise bootstrap packages status` (or `mise ls-remote <tool>`) before committing.
