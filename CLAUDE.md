# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a personal dotfiles repository managed with [chezmoi](https://www.chezmoi.io/). It contains configuration files for development tools, terminal applications, and system preferences across macOS and Linux environments.

## Architecture

- **Chezmoi templating**: Files use Go templates with OS-specific conditional logic (`.chezmoi.os`, `.chezmoi.osRelease`)
- **Cross-platform support**: macOS (Homebrew), Ubuntu/Debian (apt), and Arch Linux (pacman)
- **Modular configs**: Each application has its own directory under `dot_config/`
- **External dependencies**: Managed via `.chezmoiexternal.toml` (tmux plugins, fzf, etc.)

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
- Git repositories (tpm, fzf, base16-shell)
- Downloaded files (fisher)
- Archives (JetBrains Mono Nerd Font)

To add a new external dependency:
```toml
["target/path"]
    type = "git-repo"  # or "file", "archive"
    url = "https://github.com/user/repo.git"
    refreshPeriod = "168h"
```
