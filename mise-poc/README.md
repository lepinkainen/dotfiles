# mise-bootstrap POC harness

Disposable Docker harness to test `dot_config/mise/config.toml.tmpl` end-to-end
on throwaway Linux boxes. It renders the **real** dotfiles config with chezmoi
*inside* the container (so it picks the linux/debian or linux/arch branch from
the container's own os-release), then runs `mise bootstrap`. Reset and rerun
freely.

Lives in the dotfiles repo but is excluded from `chezmoi apply` via
`.chezmoiignore` — it is never written to `$HOME`.

## Use

```bash
./run.sh                 # build + up (debian)
DISTRO=arch ./run.sh up  # arch (Arch Linux ARM base)
./run.sh boot            # re-run bootstrap (idempotency check)
./run.sh shell           # poke around
./run.sh render          # show the rendered ~/.config/mise/config.toml
./run.sh reset           # docker rm -f
./run.sh clean           # reset + remove image
```

`DOTFILES_REPO` overrides the mounted repo (default `$HOME/projects/dotfiles`).

## Findings

- **macOS**: brew formulae + `[bootstrap.macos.defaults]` (tested via dry-run on host).
- **Debian** (`debian:trixie`): apt base packages + 16 mise `[tools]`, idempotent. ✓
- **Arch**: pacman branch validated on a real x86 host (not this harness — Arch
  ARM under Docker hit landlock/partial-upgrade friction). ✓
- `mise bootstrap` is experimental → config sets `[settings] experimental = true`.
- mise registry tool names (eza, zoxide, delta, starship, lazygit, …) resolve
  identically across all three platforms — the cross-distro payoff.

## Files

- `Dockerfile` — debian:trixie + mise + chezmoi
- `Dockerfile.arch` — Arch Linux ARM + mise + chezmoi
- `run.sh` — the harness (distro-aware via `DISTRO`)
