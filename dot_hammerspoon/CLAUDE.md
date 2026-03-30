# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal Hammerspoon (macOS automation) configuration in Lua. Manages window tiling, multi-monitor layouts, location-based layout switching, application hotkeys, and URL handling.

## Development Workflow

There is no build or test system. Edit any `.lua` file and the `ReloadConfiguration` Spoon auto-reloads Hammerspoon via pathwatcher. Check the Hammerspoon console for errors and debug output. Per-module debug logging is toggled via `config.debug` flags.

## Architecture

**config.lua** is the single source of truth — all other modules `require("config")` for display names, key modifiers, network/machine mappings, app bundle IDs, and debug flags. Never hardcode these values elsewhere.

**init.lua** bootstraps everything: loads the ReloadConfiguration Spoon, requires all modules, binds top-level hotkeys (Hyper+K for URL posting, Hyper+L for layout switching), and shows a startup notification.

### Module Responsibilities

- **rectangle.lua** — Window tiling (halves, quarters, thirds, fullscreen) bound to `Alt+Ctrl` combos. Handles multi-screen cycling: e.g., left-half on leftmost screen cycles to previous screen's right half.
- **layouts.lua** — Declarative multi-monitor layouts using `hs.layout.apply()`. Each location (home, home_laptop_only, work_at_home, work_office) has a dedicated layout function. `ApplyLayout()` detects the machine and applies the right one.
- **location.lua** — Detects location from machine hostname (`hs.host.names()`) and WiFi SSID. Tracks `currentLocation` to avoid re-applying unchanged layouts. WiFi watcher and periodic timer are currently disabled; layout is applied manually via Hyper+L.
- **applications.lua** — App launch hotkeys (Hyper+O for Obsidian with daily note, Hyper+W for window hints, Hyper+Tab for window switcher).
- **urlstore.lua** — Sends clipboard URLs to a local web service (`localhost:8080`) via async HTTP POST.
- **display_brightness.lua** — Auto-adjusts laptop brightness based on AC/battery power state. Respects manual adjustments after initial setting.
- **experimental.lua** — Grid overlay, side-by-side arrangement, app chooser.

### Key Patterns

- **Hyper key**: `{cmd, alt, ctrl, shift}` — used for all custom hotkeys
- **Rectangle key**: `{alt, ctrl}` — used for window management
- **Logger per module**: `hs.logger.new('name', config.debug.name and 'debug' or 'info')`
- **Location detection**: home machines list in `config.networks.home.machines`, work machine in `config.networks.work.machine`. Home machines are checked first; screen count distinguishes laptop-only from docked.

### Multi-Machine Setup

Two home machines: `mimic` (desktop) and `mystique` (laptop). Both match as home machines. `mystique` with only its built-in display gets `home_laptop_only` (launches apps without specific layout). With external displays, it gets the full `home` layout. Work detection uses WiFi SSID to distinguish office vs home.
