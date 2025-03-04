local hyper = { "cmd", "alt", "ctrl", "shift" }

-- Arrange the two topmost windows side by side
local function arrangeTopTwoWindowsLeftRight()
    -- Get the two topmost windows
    local win1 = hs.window.orderedWindows()[1]
    local win2 = hs.window.orderedWindows()[2]

    if win1 and win2 then
        local screen = win1:screen() -- Assuming both windows are on the same screen
        local max = screen:frame()

        -- Set window 1 to occupy the left half
        win1:setFrame({ x = max.x, y = max.y, w = max.w / 2, h = max.h }, 0)

        -- Set window 2 to occupy the right half
        win2:setFrame({
            x = max.x + max.w / 2,
            y = max.y,
            w = max.w / 2,
            h = max.h
        }, 0)
    end
end

-- Create a chooser for running applications
local chooser = hs.chooser.new(function(choice)
    if choice then
        hs.application.launchOrFocusByBundleID(choice.bundleID)
    end
end)

-- Register hotkeys for experimental features
hs.hotkey.bind(hyper, "3", function() arrangeTopTwoWindowsLeftRight() end)

-- Create a 2x2 grid with hs.grid
hs.hotkey.bind(hyper, "4", function()
    hs.grid.setGrid("2x2")
    hs.grid.setMargins("0,0")
    hs.grid.show()
end)

-- Activate application chooser
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
