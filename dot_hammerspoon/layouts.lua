local config = require("config")
local hyper = config.hyper

local log = hs.logger.new('layouts', config.debug.layouts and 'debug' or 'info')

-- Display references from config
local laptopScreen = config.displays.laptopScreen
local mainDisplay = config.displays.mainDisplay
local verticalScreen = config.displays.verticalScreen
local workDisplay = config.displays.workDisplay

-- Helper function to launch applications by bundle ID
local function launchApps(appList)
    for _, bundleID in ipairs(appList) do
        log.d("Launching app: " .. bundleID)
        hs.application.launchOrFocusByBundleID(bundleID)
    end
end

local function setMainWindowFullscreen(appName)
    local app = hs.application.get(appName)
    if app then
        log.d("Found " .. appName)
        local mainWindow = app:mainWindow()
        if mainWindow then
            log.d("Found main window")
            local result = mainWindow:setFullScreen(true)
            if result then
                log.d("Set main window fullscreen")
            else
                log.d("Failed to set main window fullscreen")
            end
        else
            log.d("No main window found")
        end
    end
end

local function unsetMainWindowFullscreen(appName)
    local app = hs.application.get(appName)
    if app then
        log.d("Found " .. appName)
        local mainWindow = app:mainWindow()
        if mainWindow then
            log.d("Found main window")
            local result = mainWindow:setFullScreen(false)
            if result then
                log.d("Unset main window fullscreen")
            else
                log.d("Failed to unset main window fullscreen")
            end
        else
            log.d("No main window found")
        end
    end
end

local function applyHomeLayout()
    local homeLayout = {
        { "Telegram", nil, verticalScreen, hs.geometry.unitrect(0, 0, 1, 0.5),   nil, nil },
        { "Discord",  nil, verticalScreen, hs.geometry.unitrect(0, 0.5, 1, 0.5), nil, nil }
    }

    -- Launch common apps and home-specific apps
    launchApps(config.layouts.apps.common)
    launchApps(config.layouts.apps.home)

    hs.layout.apply(homeLayout)
end

local function applyWorkAtHomeLayout()
    local workAtHomeLayout =
    {
        { "Telegram",    nil, verticalScreen, hs.geometry.unitrect(0, 0, 1, 0.5),   nil, nil }, -- top half
        { "Discord",     nil, verticalScreen, hs.geometry.unitrect(0, 0.5, 1, 0.5), nil, nil }, -- bottom half
        { "Slack",       nil, mainDisplay,    hs.geometry.unitrect(0.5, 0, 0.5, 1), nil, nil }, -- right half
        { "md.obsidian", nil, mainDisplay,    hs.geometry.unitrect(0, 0, 0.5, 1),   nil, nil }, -- left half
        { "WezTerm",     nil, laptopScreen,   hs.geometry.unitrect(0, 0, 1, 1),     nil, nil }, -- full screen
        { "Music",       nil, laptopScreen,   hs.geometry.unitrect(0, 0, 1, 1),     nil, nil }  -- full screen
    }

    -- Launch common apps and work-specific apps
    launchApps(config.layouts.apps.common)
    launchApps(config.layouts.apps.work)

    -- -> office to home -> unset fullscreen to make layout work
    unsetMainWindowFullscreen(config.apps.telegram.bundleID)
    unsetMainWindowFullscreen(config.apps.discord.bundleID)

    hs.layout.apply(workAtHomeLayout)
end

local function applyWorkAtOfficeLayout()
    local workAtOfficeLayout = {
        { "Telegram",    nil, laptopScreen, hs.geometry.unitrect(0, 0, 1, 1),     nil, nil }, -- full screen
        { "Discord",     nil, laptopScreen, hs.geometry.unitrect(0, 0, 1, 1),     nil, nil }, -- full screen
        { "Slack",       nil, workDisplay,  hs.geometry.unitrect(0.5, 0, 0.5, 1), nil, nil }, -- right half
        { "md.obsidian", nil, workDisplay,  hs.geometry.unitrect(0, 0, 0.5, 1),   nil, nil }, -- left half
        { "WezTerm",     nil, workDisplay,  hs.geometry.unitrect(0, 0, 0.5, 1),   nil, nil }, -- left half
        { "Music",       nil, laptopScreen, hs.geometry.unitrect(0, 0, 1, 1),     nil, nil }  -- full screen
    }

    -- Launch common apps and work-specific apps
    launchApps(config.layouts.apps.common)
    launchApps(config.layouts.apps.work)

    hs.layout.apply(workAtOfficeLayout)

    setMainWindowFullscreen(config.apps.telegram.bundleID)
    setMainWindowFullscreen(config.apps.discord.bundleID)
    setMainWindowFullscreen(config.apps.music.bundleID)
end

-- Default layout for when no specific layout applies
local function applyDefaultLayout()
    -- Simple layout that works on any machine
    local defaultLayout = {
        { "md.obsidian", nil, nil, hs.geometry.unitrect(0, 0, 0.7, 1),   nil, nil },
        { "WezTerm",     nil, nil, hs.geometry.unitrect(0.7, 0, 0.3, 1), nil, nil }
    }

    -- Launch just the common apps
    launchApps(config.layouts.apps.common)

    hs.layout.apply(defaultLayout)
end

function ApplyLayout()
    local layoutName = nil
    local machineName = hs.host.names()[1]:lower()

    if machineName:find(config.networks.home.machine) then
        applyHomeLayout()
        layoutName = "Home"
    end

    if machineName:find(config.networks.work.machine) then
        log.i("work computer")
        -- Working with plain laptop, no displays connected
        if #hs.screen.allScreens() == 1 then
            log.i("work mode - one display")
            layoutName = "Work mode - one display"
        end

        -- Working with laptop and external display(s)
        -- At home
        if hs.wifi.currentNetwork() == config.networks.home.ssids[1] and layoutName == nil then
            applyWorkAtHomeLayout()
            log.i("work mode - work at home")
            layoutName = "Work at home"
        end
        -- At the office
        if hs.wifi.currentNetwork() == config.networks.work.ssids[1] and layoutName == nil then
            applyWorkAtOfficeLayout()
            log.i("work mode - work at office")
            layoutName = "Work at office"
        end
    end

    -- Notify about applied layout
    hs.notify.new({
        autoWithdraw = true,
        title = "Hammerspoon Layout",
        informativeText = "Layout applied\n🧑🏼‍💻: " .. machineName .. "\n🪟: " .. (layoutName or "Unknown"),
        withdrawAfter = 5,
    }):send()
end

return {
    applyHomeLayout = applyHomeLayout,
    applyWorkAtHomeLayout = applyWorkAtHomeLayout,
    applyWorkAtOfficeLayout = applyWorkAtOfficeLayout,
    applyDefaultLayout = applyDefaultLayout,
    ApplyLayout = ApplyLayout
}
