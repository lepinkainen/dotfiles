# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a personal dotfiles repository managed with [chezmoi](https://www.chezmoi.io/). It contains configuration files for development tools, terminal applications, and system preferences across macOS and Linux environments.

## Architecture

- **Chezmoi templating**: Files use Go templates with OS-specific conditional logic (`.chezmoi.os`, `.chezmoi.osRelease`)
- **Cross-platform support**: macOS (Homebrew), Ubuntu/Debian (apt), and Arch Linux (pacman)
- **Modular configs**: Each application has its own directory under `dot_config/`
- **External dependencies**: Managed via `.chezmoiexternal.toml` (tmux tpm, fisher, fonts)
- **Secrets**: age-encrypted files (`encrypted_*.age`); recipients in `key/recipients.txt`

## Common Commands

### Package Management

```bash
# Apply all dotfiles changes
chezmoi apply

# Preview changes without applying
chezmoi diff

# Add new dotfiles to chezmoi management
chezmoi add ~/.config/newapp/config.toml

# Edit a managed file
chezmoi edit ~/.gitconfig

# Update external dependencies
chezmoi update

# Install packages based on OS
./run_onchange_install-packages.sh
```

### Development Workflow

```bash
# Test changes in a temporary directory
chezmoi execute-template < template_file

# Debug template variables
chezmoi data

# Update from git and apply
chezmoi update
```

## Key Configurations

- **Terminal**: Fish shell with starship prompt, tmux, multiple terminal emulators (wezterm, alacritty)
- **Editor**: Neovim with Lua configuration in `dot_config/nvim/`
- **Development**: Git, direnv, atuin (shell history), various CLI tools
- **macOS specific**: Hammerspoon (window management), Karabiner-Elements (key mapping)

## File Naming Conventions

- `dot_` prefix → `.` (hidden files)
- `private_` prefix → Files that should not be world-readable
- `run_onchange_` → Scripts that run when the file changes
- `.tmpl` suffix → Go templates that get processed

## Package Installation

Package installation is triggered by `run_onchange_install-packages.sh.tmpl`, which calls `bin/install-packages.sh`. The actual install script is generated from `bin/executable_install-packages.sh.tmpl` using chezmoi templating.

### How It Works by OS

#### macOS
- **Package manager**: Homebrew
- **Package list**: `Brewfile` (root of chezmoi source)
- **Process**: 
  1. Installs Homebrew if missing
  2. Runs `brew bundle` to install from Brewfile
  3. Installs additional casks (Hammerspoon, Karabiner-Elements)
  4. Installs Nerd Fonts

#### Linux (Debian/Ubuntu)
- **Package manager**: apt
- **Package list**: Defined in `bin/executable_install-packages.sh.tmpl` as `$base_packages`
- **Process**: `sudo apt update && sudo apt install -y <packages>`

#### Linux (Arch)
- **Package manager**: pacman
- **Package list**: Same as Debian but with name substitutions (e.g., `fd-find` → `fd`)
- **Process**: `sudo pacman -Syu --noconfirm <packages>`

#### npm (Global Packages - All Platforms)
- **Package manager**: npm
- **Package list**: `npmfile` (root of chezmoi source)
- **Trigger**: `run_onchange_install-npm-packages.sh.tmpl` runs when `npmfile` changes
- **Process**: Reads packages from npmfile, runs `npm install -g` for each

### Adding New Packages

#### macOS
Add to `Brewfile`:
```ruby
# CLI tools
brew "package-name"

# GUI applications
cask "app-name"
```

#### Linux
Edit `bin/executable_install-packages.sh.tmpl`:
1. Add to `$base_packages` variable for Debian/Ubuntu
2. If the package has a different name on Arch, add a `replace` call for `$arch_packages`

Example:
```go
{{- $base_packages := "existing-packages new-package" -}}
{{- $arch_packages := replace $base_packages "new-package" "arch-package-name" -}}
```

#### npm (Global)
Add to `npmfile` (one package per line):
```
# Comments start with #
@scope/package-name
another-package
```

The install script runs automatically on `chezmoi apply` when npmfile changes.

### External Dependencies

Some tools are installed via `.chezmoiexternal.toml.tmpl`:
- Git repositories (tpm)
- Downloaded files (fisher)
- Archives (JetBrains Mono Nerd Font — Linux only; macOS gets it via brew cask)

To add a new external dependency:
```toml
["target/path"]
    type = "git-repo"  # or "file", "archive"
    url = "https://github.com/user/repo.git"
    refreshPeriod = "168h"
```

## Secrets / Encryption (age)

Encrypted files use [age](https://age-encryption.org). Source files are named
`encrypted_*.age` (e.g. `private_dot_ssh/encrypted_config.age` → `~/.ssh/config`).

### Config

Each machine's `~/.config/chezmoi/chezmoi.toml` (NOT committed) declares:
```toml
encryption = "age"
[age]
    identity = "~/.config/chezmoi/key.txt"
    recipientsFile = "~/.local/share/chezmoi/key/recipients.txt"
```
- `identity` = this machine's age **private** key (`key.txt`, machine-local, never committed).
- `recipientsFile` = shared list of all machines' **public** keys, committed at
  `key/recipients.txt`. `key/` is in `.chezmoiignore` so it is not deployed to `~`.

Decryption needs only `identity`. Encryption (`chezmoi re-add` / `chezmoi edit`)
encrypts to every pubkey in `recipientsFile`.

### Adding a new machine

1. On the new machine: `age-keygen -o ~/.config/chezmoi/key.txt`, note its public key.
2. Append the pubkey to `key/recipients.txt` (one per line, `# name` comment).
3. From any machine that can already decrypt, re-encrypt and push:
   ```bash
   chezmoi re-add ~/.ssh/config
   chezmoi git -- add . && chezmoi git -- commit -m "chore: add recipient" && chezmoi git -- push
   ```
4. New machine: `chezmoi update` — its key is now a baked recipient.

**Gotcha:** adding a pubkey to `recipientsFile` does nothing to existing `.age`
files until they are re-encrypted (`chezmoi re-add`) and committed. A machine whose
key was added but never re-encrypted into a file gets
`age: error: no identity matched any of the recipients`.
