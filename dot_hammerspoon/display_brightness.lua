--[[
display_brightness.lua
Manages the brightness of the built-in display based on power source and session state.
- Sets brightness to a configured level when a "session" starts (Hammerspoon load, system wake, power source change).
- Notifies once per session when automatic adjustment occurs.
- Respects manual brightness changes made after the initial automatic adjustment for the current session and power mode.
--]]

-- External Hammerspoon Modules
local battery = require("hs.battery")
local screen = require("hs.screen")
local timer = require("hs.timer")
local notify = require("hs.notify")
local caffeinate = require("hs.caffeinate")
local inspect = require("hs.inspect") -- For debugging

-- Module Table
local M = {}

-- --- Configuration ---

-- Attempt to load global configuration and resolve it
-- MODIFICATION: Correctly handle pcall return values
local loadSuccess, loadedConfigOrError = pcall(require, "config")
local resolvedGlobalConfig -- This will hold the actual configuration table or defaults

if loadSuccess and type(loadedConfigOrError) == "table" then
    -- Successfully loaded config.lua and it returned a table
    resolvedGlobalConfig = loadedConfigOrError
    print("display_brightness.lua: Successfully loaded global 'config.lua'.")
else
    -- config.lua either failed to load, or didn't return a table
    if not loadSuccess then
        -- pcall itself failed (e.g., file not found, syntax error in config.lua)
        print("display_brightness.lua: Error loading global 'config.lua': " ..
        tostring(loadedConfigOrError) .. ". Using default settings.")
    else
        -- pcall succeeded, but require("config") did not return a table
        print("display_brightness.lua: Global 'config.lua' loaded but did not return a table (type: " ..
        type(loadedConfigOrError) .. "). Using default settings.")
    end
    -- Provide minimal defaults if global config is missing or invalid
    resolvedGlobalConfig = {
        debug = { brightness = false },
        displays = { laptopScreen = "Built-in Retina Display" }
    }
end

-- Define moduleConfig using resolvedGlobalConfig
-- These are the default settings for the module, potentially overridden.
local moduleConfig = {
    scriptName = "BrightnessControl",
    -- MODIFICATION: Use resolvedGlobalConfig and safe navigation
    targetDisplayName = (resolvedGlobalConfig.displays and resolvedGlobalConfig.displays.laptopScreen) or
    "Built-in Retina Display",
    acBrightnessLevel = 1.0,      -- Brightness level for AC power (100%)
    batteryBrightnessLevel = 0.8, -- Brightness level for Battery power (80%)
    initialCheckDelay = 3.0,      -- Seconds to wait after HS load before initial check
    -- MODIFICATION: Use resolvedGlobalConfig and safe navigation
    logLevel = ((resolvedGlobalConfig.debug and resolvedGlobalConfig.debug.brightness) and 'debug') or 'info',
    version = "2.0.1 (Corrected Config Loading)" -- Updated version
}

-- --- State Variables ---
-- These flags track if the initial brightness adjustment has been performed for the current session
-- on a given power mode. A "session" can be considered:
-- 1. Hammerspoon loading/reloading.
-- 2. System waking from sleep.
-- 3. Switching to a new power source (e.g., battery to AC or AC to battery).
local state = {
    acBrightnessInitialSetDoneThisSession = false,
    batteryBrightnessInitialSetDoneThisSession = false,
    powerWatcher = nil,
    wakeWatcher = nil,
    initialTimer = nil
}

-- --- Logger ---
-- Logger is initialized after moduleConfig, so it uses the potentially overridden logLevel
local log = hs.logger.new(moduleConfig.scriptName, moduleConfig.logLevel)

-- --- Core Utility Functions ---

--[[
Finds the screen object for the configured internal display.
@return hs.screen object or nil if not found.
--]]
local function getInternalDisplay()
    log.d("Attempting to find display: " .. moduleConfig.targetDisplayName)
    local allScreens = screen.allScreens()
    if not allScreens or #allScreens == 0 then
        log.w("No screens found.")
        return nil
    end

    for _, s in ipairs(allScreens) do
        local ok, currentScreenName = pcall(s.name, s) -- Safely get screen name
        if ok and currentScreenName and currentScreenName == moduleConfig.targetDisplayName then
            log.d("Found target display: " .. moduleConfig.targetDisplayName)
            return s
        elseif not ok then
            log.w("Error getting name for a screen object:", inspect(s), "Error:", currentScreenName)
        end
    end
    log.w("Display named '" .. moduleConfig.targetDisplayName .. "' not found.")
    return nil
end

--[[
Sets the brightness for the target display and optionally sends a notification.
@param level (number) The desired brightness level (0.0 to 1.0).
@param shouldNotify (boolean) If true, a notification will be sent.
@param powerModeForNotification (string, optional) "AC" or "Battery" to include in notification.
--]]
local function setDisplayBrightness(level, shouldNotify, powerModeForNotification)
    level = math.max(0.0, math.min(1.0, level or 0.0)) -- Clamp level
    local levelPercent = string.format("%.0f%%", level * 100)

    log.d("Attempting to set brightness to " ..
    levelPercent .. " for '" .. moduleConfig.targetDisplayName .. "'. Notify: " .. tostring(shouldNotify))

    local targetScreen = getInternalDisplay()
    if not targetScreen then
        log.w("Cannot set brightness, target display not found.")
        return
    end

    local success, err = pcall(targetScreen.setBrightness, targetScreen, level) -- Capture error message on failure
    if success then
        log.i("Successfully set brightness to " .. levelPercent .. " on '" .. moduleConfig.targetDisplayName .. "'.")
        if shouldNotify then
            local notificationText = "'" .. moduleConfig.targetDisplayName .. "' brightness set to " .. levelPercent
            if powerModeForNotification then
                notificationText = notificationText .. " (" .. powerModeForNotification .. " Power)"
            end
            notify.new({
                title = moduleConfig.scriptName,
                informativeText = notificationText
            }):send()
            log.d("Notification sent for brightness change.")
        end
    else
        -- MODIFICATION: Log the actual error message from pcall
        log.e("Failed to set brightness on '" .. moduleConfig.targetDisplayName .. "'. Error: " .. tostring(err))
    end
end

-- --- Logic Functions for Session Management ---

--[[
Applies the initial brightness setting based on the current power source.
This is typically called at the "start" of a session (HS load, system wake).
It always notifies because it's considered an initial, automatic adjustment.
--]]
local function applySessionStartBrightness()
    log.i("Applying session start brightness...")
    local currentPowerSource = battery.powerSource()
    log.d("Current power source for session start: " .. (currentPowerSource or "Unknown"))

    if currentPowerSource == "AC Power" then
        log.i("Session start on AC Power. Setting brightness to " .. moduleConfig.acBrightnessLevel * 100 .. "%.")
        setDisplayBrightness(moduleConfig.acBrightnessLevel, true, "AC")
        state.acBrightnessInitialSetDoneThisSession = true
        state.batteryBrightnessInitialSetDoneThisSession = false -- Reset other mode's flag
    elseif currentPowerSource == "Battery Power" then
        log.i("Session start on Battery Power. Setting brightness to " ..
        moduleConfig.batteryBrightnessLevel * 100 .. "%.")
        setDisplayBrightness(moduleConfig.batteryBrightnessLevel, true, "Battery")
        state.batteryBrightnessInitialSetDoneThisSession = true
        state.acBrightnessInitialSetDoneThisSession = false -- Reset other mode's flag
    else
        log.w("Session start on Unknown power source ('" ..
        (currentPowerSource or "nil") .. "'). No brightness action taken.")
    end
end

-- --- Event Handler Callbacks ---

--[[
Callback for hs.battery.watcher. Handles power source changes.
--]]
local function powerSourceChangedCallback()
    local newPowerSource = battery.powerSource()
    log.i("Power source changed. New source: " .. (newPowerSource or "Unknown"))

    if newPowerSource == "AC Power" then
        if not state.acBrightnessInitialSetDoneThisSession then
            log.i("Switched to AC Power. Initial AC brightness not yet set this session. Setting now.")
            setDisplayBrightness(moduleConfig.acBrightnessLevel, true, "AC")
            state.acBrightnessInitialSetDoneThisSession = true
        else
            log.d(
            "Switched to AC Power, but initial AC brightness was already set this session. Respecting manual changes.")
        end
        state.batteryBrightnessInitialSetDoneThisSession = false -- Reset other mode's flag
    elseif newPowerSource == "Battery Power" then
        if not state.batteryBrightnessInitialSetDoneThisSession then
            log.i("Switched to Battery Power. Initial battery brightness not yet set this session. Setting now.")
            setDisplayBrightness(moduleConfig.batteryBrightnessLevel, true, "Battery")
            state.batteryBrightnessInitialSetDoneThisSession = true
        else
            log.d(
            "Switched to Battery Power, but initial battery brightness was already set this session. Respecting manual changes.")
        end
        state.acBrightnessInitialSetDoneThisSession = false -- Reset other mode's flag
    else
        log.w("Power source changed to an unexpected value: '" .. (newPowerSource or "nil") .. "'. No brightness action.")
    end
end

--[[
Callback for hs.caffeinate.watcher. Handles system wake events.
--]]
local function systemWakeCallback(event)
    if event == caffeinate.watcher.systemDidWake then
        log.i("System woke from sleep. Treating as a new session start.")
        applySessionStartBrightness()
    elseif event == caffeinate.watcher.systemWillSleep then
        log.d("System will sleep. No action needed by brightness controller.")
        -- Optional: Could reset flags here if sleep should definitively end a "session"
        -- state.acBrightnessInitialSetDoneThisSession = false
        -- state.batteryBrightnessInitialSetDoneThisSession = false
    end
end

-- --- Module Control Functions ---

--[[
Starts the brightness controller: sets up watchers and initial check.
--]]
function M:start()
    log.i("Starting BrightnessControl module (Version: " .. moduleConfig.version .. ")")
    log.d("Target Display: " .. moduleConfig.targetDisplayName)
    log.d("AC Brightness: " .. moduleConfig.acBrightnessLevel * 100 .. "%")
    log.d("Battery Brightness: " .. moduleConfig.batteryBrightnessLevel * 100 .. "%")

    -- Stop existing watchers if any (e.g., during a reload)
    self:stop()

    -- Start power source watcher
    state.powerWatcher = battery.watcher.new(powerSourceChangedCallback)
    if state.powerWatcher then
        state.powerWatcher:start()
        log.d("Battery watcher started.")
    else
        log.e("Failed to create battery watcher.")
    end

    -- Start system wake watcher
    state.wakeWatcher = caffeinate.watcher.new(systemWakeCallback)
    if state.wakeWatcher then
        state.wakeWatcher:start()
        log.d("System wake watcher started.")
    else
        log.e("Failed to create system wake watcher.")
    end

    -- Perform an initial check after a short delay
    log.d("Scheduling initial brightness check in " .. moduleConfig.initialCheckDelay .. " seconds.")
    state.initialTimer = timer.doAfter(moduleConfig.initialCheckDelay, function()
        log.i("Initial timer fired. Performing first brightness check.")
        applySessionStartBrightness()
    end)

    notify.new({
        title = moduleConfig.scriptName,
        informativeText = "Brightness Control Script Loaded (" .. moduleConfig.version .. ")"
    }):send()
    log.i("BrightnessControl module started successfully.")
end

--[[
Stops the brightness controller: removes watchers and timers.
--]]
function M:stop()
    log.i("Stopping BrightnessControl module...")
    if state.powerWatcher then
        state.powerWatcher:stop()
        state.powerWatcher = nil
        log.d("Battery watcher stopped.")
    end
    if state.wakeWatcher then
        state.wakeWatcher:stop()
        state.wakeWatcher = nil
        log.d("System wake watcher stopped.")
    end
    if state.initialTimer then
        state.initialTimer:stop()
        state.initialTimer = nil
        log.d("Initial check timer stopped.")
    end
    log.i("BrightnessControl module stopped.")
end

-- Return the module
return M
