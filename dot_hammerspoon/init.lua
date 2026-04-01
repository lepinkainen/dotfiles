-- Trigger Location Services permission prompt (needed for WiFi SSID access)
if hs.location.servicesEnabled() then
    hs.location.start()

    hs.timer.doAfter(2, function()
        local location = hs.location.get()
        if location then
            print("Current Location:")
            print("Latitude: " .. (location.latitude or "N/A"))
            print("Longitude: " .. (location.longitude or "N/A"))
            print("Altitude: " .. (location.altitude or "N/A"))
            print("Horizontal Accuracy: " .. (location.horizontalAccuracy or "N/A"))
            print("Vertical Accuracy: " .. (location.verticalAccuracy or "N/A"))
        else
            print("Unable to retrieve location information.")
        end

        hs.location.stop()
    end)
else
    print("Location services are not enabled.")
end

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
require "display_brightness"
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
