local hyper = {"cmd", "alt", "ctrl", "shift"}

hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

function hs.reloadConfig()
    hs.reload()
    -- Send a notification
    hs.notify.new({
        title = "Hammerspoon",
        informativeText = "Configuration Reloaded!"
    }):send()
end
hs.hotkey.bind({"cmd", "alt", "ctrl", "shift"}, "r", hs.reloadConfig)

hs.application.enableSpotlightForNameSearches(true)

require "rectangle"
require "layouts"
require "applications"

function arrangeTopTwoWindowsLeftRight()
    -- Get the two topmost windows
    local win1 = hs.window.orderedWindows()[1]
    local win2 = hs.window.orderedWindows()[2]

    if win1 and win2 then
        local screen = win1:screen() -- Assuming both windows are on the same screen
        local max = screen:frame()

        -- Set window 1 to occupy the left half
        win1:setFrame({
            x = max.x,
            y = max.y,
            w = max.w / 2,
            h = max.h
        }, 0)

        -- Set window 2 to occupy the right half
        win2:setFrame({
            x = max.x + max.w / 2,
            y = max.y,
            w = max.w / 2,
            h = max.h
        }, 0)
    end
end

hs.hotkey.bind(hyper, "3", function()
    arrangeTopTwoWindowsLeftRight()
end)

-- create a 2x2 grid with hs.grid
hs.hotkey.bind(hyper, "4", function()
    hs.grid.setGrid("2x2")
    hs.grid.setMargins("0,0")
    hs.grid.show()
end)

-- activate chooser
hs.hotkey.bind(hyper, "5", function()
    local choices = {}
    for _, app in ipairs(hs.application.runningApplications()) do
        table.insert(choices, {
            text = app:name(),
            subText = app:bundleID(),
            bundleID = app:bundleID()
        })
    end
    chooser:choices(choices)
    chooser:show()
end)

-- list available displays
-- hs.fnutils.each(hs.screen.allScreens(), function(screen) print(screen) end)

if hs.host.names()[1]:lower():find("mimic") then
    homeLayout()
end

-- To enable wifi network detection:
-- type print(hs.location.get()) in the console
-- go to System Preferences -> Security & Privacy -> Privacy -> Location Services
-- check Hammerspoon
if hs.host.names()[1]:lower():find("mystique") then
    if hs.wifi.currentNetwork() == nil then
        print("work mode - no wifi")
    end
    if hs.wifi.currentNetwork() == "Rocinante-5G" then
        workAtHomeLayout()
    end
    if hs.wifi.currentNetwork() == "somethingelse" then
        workAtOfficeLayout()
    end

    hs.notify.new({
        autoWithdraw = true,
        title = "Hammerspoon Layout",
        informativeText = "Layout applied",
        withdrawAfter = 2,
        contentimage = hs.image.imageFromPath("/Users/riku.lindblad/Pictures/avatar.png"),
        setIdImage = hs.image.imageFromPath("/Users/riku.lindblad/Pictures/avatar.png")
    }):send()
end
