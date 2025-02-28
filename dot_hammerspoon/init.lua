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
local location = require "location" -- New location module

-- Set up console behavior
hs.console.darkMode(true)
hs.console.consoleFont({ name = "Menlo", size = 12 })

-- post url from clipboard to local downloader service
hs.hotkey.bind(hyper, "k", PostURLtoWebService)

-- set layout based on location (manual trigger)
hs.hotkey.bind(hyper, "l", function() location.manualApplyLayout() end)

-- Notify that config is loaded
hs.notify.new({
    title = "Hammerspoon",
    informativeText = "🔨Configuration loaded successfully",
    withdrawAfter = 3
}):send()
