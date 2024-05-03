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
        win1:setFrame({x = max.x, y = max.y, w = max.w / 2, h = max.h}, 0)

        -- Set window 2 to occupy the right half
        win2:setFrame({
            x = max.x + max.w / 2,
            y = max.y,
            w = max.w / 2,
            h = max.h
        }, 0)
    end
end

hs.hotkey.bind(hyper, "3", function() arrangeTopTwoWindowsLeftRight() end)
