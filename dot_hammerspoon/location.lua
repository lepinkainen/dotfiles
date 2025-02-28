local config = require("config")
local layouts = require("layouts")

local log = hs.logger.new('location', config.debug.location and 'debug' or 'info')
local wifi = hs.wifi
local timer = hs.timer
local host = hs.host

-- Current location
local currentLocation = nil

-- Detect location based on machine name and WiFi SSID
local function detectLocation()
    local currentSSID = wifi.currentNetwork()
    local machineName = host.names()[1]:lower()

    log.i("Current WiFi SSID: " .. (currentSSID or "None"))
    log.i("Machine name: " .. machineName)

    -- Check if we're at home
    if machineName:find(config.networks.home.machine) or
        (currentSSID and hs.fnutils.contains(config.networks.home.ssids, currentSSID)) then
        return "home"
    end

    -- Check if we're at work
    if machineName:find(config.networks.work.machine) then
        -- At work with laptop only
        if #hs.screen.allScreens() == 1 then
            return "work_laptop_only"
        end

        -- At work with external display
        if currentSSID and hs.fnutils.contains(config.networks.work.ssids, currentSSID) then
            return "work_office"
        end

        -- At home with work laptop
        if currentSSID and hs.fnutils.contains(config.networks.home.ssids, currentSSID) then
            return "work_at_home"
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
        if location == "home" then
            layouts.applyHomeLayout()
        elseif location == "work_at_home" then
            layouts.applyWorkAtHomeLayout()
        elseif location == "work_office" then
            layouts.applyWorkAtOfficeLayout()
        elseif location == "work_laptop_only" then
            -- You could add a new layout function for this case
            log.i("No specific layout for work laptop only")
        else
            log.i("No specific layout for this location")
        end

        -- Show notification
        hs.notify.new({
            title = "Hammerspoon",
            informativeText = "Applied " .. location .. " layout",
            withdrawAfter = 3
        }):send()
    end
end

-- Watch for WiFi network changes - DISABLED for manual control only
-- local wifiWatcher = wifi.watcher.new(applyLayoutForLocation)
-- wifiWatcher:start()

-- Also check periodically (for when returning from sleep) - DISABLED for manual control only
-- local locationTimer = timer.new(300, applyLayoutForLocation)
-- locationTimer:start()

-- Initial check - DISABLED for manual control only
-- applyLayoutForLocation()

-- Manual layout application function (to be called by hyper-L)
local function manualApplyLayout()
    applyLayoutForLocation()
end

return {
    detectLocation = detectLocation,
    applyLayoutForLocation = applyLayoutForLocation,
    manualApplyLayout = manualApplyLayout
}
