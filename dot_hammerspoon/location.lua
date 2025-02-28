local config = require("config")
local layouts = require("layouts")

local log = hs.logger.new('location', 'info')
local wifi = hs.wifi
local timer = hs.timer

-- Known locations based on WiFi networks
local knownLocations = {
    home = {
        ssids = { "HomeWiFi", "HomeWiFi-5G" },
        layout = layouts.applyHomeLayout
    },
    work = {
        ssids = { "WorkWiFi", "Office-Guest" },
        layout = layouts.applyWorkLayout
    },
    other = {
        layout = layouts.applyDefaultLayout
    }
}

-- Current location
local currentLocation = nil

-- Detect location based on WiFi SSID
local function detectLocation()
    local currentSSID = wifi.currentNetwork()
    log.i("Current WiFi SSID: " .. (currentSSID or "None"))

    -- Check if we're at a known location
    for location, config in pairs(knownLocations) do
        if config.ssids then
            for _, ssid in ipairs(config.ssids) do
                if currentSSID == ssid then
                    return location
                end
            end
        end
    end

    -- Default to "other" if no match
    return "other"
end

-- Apply layout based on current location
local function applyLayoutForLocation()
    local location = detectLocation()

    -- Only apply if location changed
    if location ~= currentLocation then
        log.i("Location changed to: " .. location)
        currentLocation = location

        -- Apply the layout for this location
        if knownLocations[location] and knownLocations[location].layout then
            knownLocations[location].layout()

            -- Show notification
            hs.notify.new({
                title = "Hammerspoon",
                informativeText = "Applied " .. location .. " layout",
                withdrawAfter = 3
            }):send()
        end
    end
end

-- Watch for WiFi network changes
local wifiWatcher = wifi.watcher.new(applyLayoutForLocation)
wifiWatcher:start()

-- Also check periodically (for when returning from sleep)
local locationTimer = timer.new(300, applyLayoutForLocation)
locationTimer:start()

-- Initial check
applyLayoutForLocation()

return {
    detectLocation = detectLocation,
    applyLayoutForLocation = applyLayoutForLocation,
    addLocation = function(name, ssids, layoutFn)
        knownLocations[name] = {
            ssids = ssids,
            layout = layoutFn
        }
    end
}
