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

The `run_onchange_install-packages.sh.tmpl` handles OS-specific package installation:

- macOS: Uses Homebrew and the `Brewfile`
- Ubuntu/Debian: Uses apt with predefined package list
- Arch Linux: Uses pacman with adjusted package names
