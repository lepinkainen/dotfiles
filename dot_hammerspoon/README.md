# Hammerspoon Configuration

This is my personal Hammerspoon configuration for macOS automation and window management.

## Features

- **Window Management**: Rectangle-like window management with keyboard shortcuts
- **Layout Management**: Apply different window layouts based on location/connected displays
- **URL Handling**: Send URLs from clipboard to a local download service
- **Application Shortcuts**: Quick launch and control of applications
- **Experimental Features**: Various experimental utilities

## Keyboard Shortcuts

### Window Management (Alt+Ctrl)

- Left/Right/Up/Down: Move window to left/right/top/bottom half of screen
- U/I/J/K: Move window to top-left/top-right/bottom-left/bottom-right quarter
- F: Maximize window
- C: Center window
- Left+Right: Next/Previous display

### Hyper Key (Cmd+Alt+Ctrl+Shift)

- K: Post URL from clipboard to local downloader service
- L: Apply layout based on location
- O: Launch Obsidian and open daily note
- 3: Arrange top two windows side by side
- 4: Show 2x2 grid
- 5: Show application chooser

## Structure

- `init.lua`: Main configuration file
- `config.lua`: Centralized configuration settings
- `rectangle.lua`: Window management functionality
- `layouts.lua`: Screen layout management
- `applications.lua`: Application-specific shortcuts
- `urlstore.lua`: URL handling functionality
- `experimental.lua`: Experimental features
- `Spoons/`: Hammerspoon extension modules

## Requirements

- [Hammerspoon](https://www.hammerspoon.org/) (tested with version 0.9.97+)
- macOS (tested with macOS Ventura)

## Installation

1. Install Hammerspoon
2. Clone this repository to `~/.hammerspoon/`
3. Launch Hammerspoon
4. Adjust configuration in `config.lua` as needed
