local hyper = { "cmd", "alt", "ctrl", "shift" }

local log = hs.logger.new('layouts', 'info')

-- list available displays
-- hs.fnutils.each(hs.screen.allScreens(), function(screen) print(screen) end)
local laptopScreen = "Built-in Retina Display"
local mainDisplay = "L32p-30"
local verticalScreen = "LEN P27h-10"
local workDisplay = "LEN P32p-20"

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

    hs.application.launchOrFocusByBundleID("ru.keepcoder.Telegram")
    hs.application.launchOrFocusByBundleID("com.hnc.Discord")
    hs.application.launchOrFocusByBundleID("md.obsidian")
    hs.application.launchOrFocusByBundleID("com.apple.Music")
    hs.application.launchOrFocus("IRCCloud")

    hs.layout.apply(homeLayout)
end

local function applyWorkAtHomeLayout()
    local workAtHomeLayout =
    {
        { "Telegram",    nil, verticalScreen, hs.geometry.unitrect(0, 0, 1, 0.5),   nil, nil },  -- top half
        { "Discord",     nil, verticalScreen, hs.geometry.unitrect(0, 0.5, 1, 0.5), nil, nil },  -- bottom half
        { "Slack",       nil, mainDisplay,    hs.geometry.unitrect(0.5, 0, 0.5, 1), nil, nil },  -- right half
        { "md.obsidian", nil, mainDisplay,    hs.geometry.unitrect(0, 0, 0.5, 1),   nil, nil },  -- left half
        { "WezTerm",     nil, laptopScreen,   hs.geometry.unitrect(0, 0, 1, 1),     nil, nil },  -- full screen
        { "Music",       nil, laptopScreen,   hs.geometry.unitrect(0, 0, 1, 1),     nil, nil }   -- full screen
    }

    -- hs.fnutils.each(hs.application.runningApplications(), function(app) print(app:bundleID()) end)
    hs.application.launchOrFocusByBundleID("ru.keepcoder.Telegram")
    hs.application.launchOrFocusByBundleID("com.hnc.Discord")
    hs.application.launchOrFocusByBundleID("md.obsidian")
    hs.application.launchOrFocusByBundleID("com.tinyspeck.slackmacgap")
    hs.application.launchOrFocusByBundleID("com.apple.Music")
    hs.application.launchOrFocusByBundleID("com.github.wez.wezterm")

    -- -> office to home -> unset fullscreen to make layout work
    unsetMainWindowFullscreen("ru.keepcoder.Telegram")
    unsetMainWindowFullscreen("com.hnc.Discord")

    hs.layout.apply(workAtHomeLayout)
end

local function applyWorkAtOfficeLayout()
    local workAtOfficeLayout = {
        { "Telegram",    nil, laptopScreen, hs.geometry.unitrect(0, 0, 1, 1),     nil, nil },  -- full screen
        { "Discord",     nil, laptopScreen, hs.geometry.unitrect(0, 0, 1, 1),     nil, nil },  -- full screen
        { "Slack",       nil, workDisplay,  hs.geometry.unitrect(0.5, 0, 0.5, 1), nil, nil },  -- right half
        { "md.obsidian", nil, workDisplay,  hs.geometry.unitrect(0, 0, 0.5, 1),   nil, nil },  -- left half
        { "WezTerm",     nil, workDisplay,  hs.geometry.unitrect(0, 0, 0.5, 1),   nil, nil },  -- left half
        { "Music",       nil, laptopScreen, hs.geometry.unitrect(0, 0, 1, 1),     nil, nil }   -- full screen
    }

    hs.application.launchOrFocusByBundleID("md.obsidian")
    hs.application.launchOrFocusByBundleID("com.tinyspeck.slackmacgap")
    hs.application.launchOrFocusByBundleID("com.apple.Music")
    hs.application.launchOrFocusByBundleID("com.github.wez.wezterm")
    hs.application.launchOrFocusByBundleID("ru.keepcoder.Telegram")
    hs.application.launchOrFocusByBundleID("com.hnc.Discord")

    hs.layout.apply(workAtOfficeLayout)

    setMainWindowFullscreen("ru.keepcoder.Telegram")
    setMainWindowFullscreen("com.hnc.Discord")
    setMainWindowFullscreen("Music")
end

function ApplyLayout()
    local layoutName = nil
    local machineName = hs.host.names()[1]:lower()

    if machineName:find("mimic") then
        applyHomeLayout()
        layoutName = "Home"
    end

    -- To enable wifi network detection:
    -- type print(hs.location.get()) in the console
    -- go to System Preferences -> Security & Privacy -> Privacy -> Location Services
    -- check Hammerspoon
    if machineName:find("mystique") then
        log.i("work computer")
        -- Working with plain laptop, no displays connected
        if #hs.screen.allScreens() == 1 then
            log.i("work mode - one display")
            layoutName = "Work mode - one display"
        end

        -- Working with laptop and external display(s)
        -- At home
        if hs.wifi.currentNetwork() == "Rocinante-5G" and layoutName == nil then
            applyWorkAtHomeLayout()
            log.i("work mode - work at home")
            layoutName = "Work at home"
        end
        -- At the office
        if hs.wifi.currentNetwork() == "Metacore" and layoutName == nil then
            applyWorkAtOfficeLayout()
            log.i("work mode - work at office")
            layoutName = "Work at office"
        end
    end

    -- Notify about applied layout
    hs.notify.new({
        autoWithdraw = true,
        title = "Hammerspoon Layout",
        informativeText = "Layout applied\n🧑🏼‍💻: " .. machineName .. "\n🪟: " .. layoutName,
        withdrawAfter = 5,
    }):send()
end
