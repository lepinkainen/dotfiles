-- Load configuration
local config = require("config")
local hyper = config.hyper

-- Load Spoons
hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

-- Enable Spotlight for application searches
hs.application.enableSpotlightForNameSearches(true)

-- Load modules
require "rectangle"
require "layouts"
require "applications"
require "urlstore"
require "experimental"
require "location" -- New location module

-- Set up console behavior
hs.console.darkMode(true)
hs.console.consoleFont({ name = "Menlo", size = 12 })

-- post url from clipboard to local downloader service
hs.hotkey.bind(hyper, "k", PostURLtoWebService)

-- set layout based on location (manual trigger)
hs.hotkey.bind(hyper, "l", function() ApplyLayout() end)

-- Show help overlay with available shortcuts
hs.hotkey.bind(hyper, "/", function()
    local helpText = [[
Hammerspoon Shortcuts:

Window Management (Alt+Ctrl):
- Left/Right/Up/Down: Move window to half screen
- U/I/J/K: Move window to quarter screen
- F: Fullscreen window
- C: Center window

Hyper Key (Cmd+Alt+Ctrl+Shift):
- K: Post URL from clipboard to downloader
- U: Post multiple URLs from clipboard
- L: Apply layout manually

Application Shortcuts:
- O: Launch Obsidian and open daily note
- T: Launch Terminal
- B: Launch Safari
- C: Launch Visual Studio Code
- E: Launch Mail
- M: Launch Music
- N: Launch Notes
- G: Launch Telegram
- D: Launch Discord
- S: Launch Slack
- Z: Launch WezTerm

Window Management:
- W: Show window hints
- Tab: Switch between windows
- 3: Arrange top two windows side by side
- 4: Show 2x2 grid
- 5: Show application chooser
- /: Show this help
    ]]

    hs.alert.show(helpText, 10)
end)

-- Alert that config is loaded
hs.alert.show("Hammerspoon config loaded", 1)
