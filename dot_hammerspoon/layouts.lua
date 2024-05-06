local hyper = {"cmd", "alt", "ctrl", "shift"}

local laptopScreen = "Built-in Retina Display"
local mainDisplay = "L32p-30"
local verticalScreen = "LEN P27h-10"
local workDisplay = "FOO"

function homeLayout()
    local homeLayout = {{"Telegram", nil, verticalScreen, hs.geometry.unitrect(0, 0, 1, 0.5), nil, nil},
                        {"Discord", nil, verticalScreen, hs.geometry.unitrect(0, 0.5, 1, 0.5), nil, nil}}

    hs.application.launchOrFocusByBundleID("ru.keepcoder.Telegram")
    hs.application.launchOrFocusByBundleID("com.hnc.Discord")
    hs.application.launchOrFocusByBundleID("md.obsidian")
    hs.application.launchOrFocusByBundleID("com.apple.Music")

    hs.layout.apply(homeLayout)
end

function workAtHomeLayout()
    local workAtHomeLayout =
        {{"Telegram", nil, verticalScreen, hs.geometry.unitrect(0, 0, 1, 0.5), nil, nil}, -- top half
        {"Discord", nil, verticalScreen, hs.geometry.unitrect(0, 0.5, 1, 0.5), nil, nil}, -- bottom half
        {"Slack", nil, mainDisplay, hs.geometry.unitrect(0.5, 0, 0.5, 1), nil, nil}, -- right half
        {"md.obsidian", nil, mainDisplay, hs.geometry.unitrect(0, 0, 0.5, 1), nil, nil}, -- left half        
        {"iTerm2", nil, laptopScreen, hs.geometry.unitrect(0, 0, 1, 1), nil, nil}, -- full screen
        {"Music", nil, laptopScreen, hs.geometry.unitrect(0, 0, 1, 1), nil, nil} -- full screen
        }

    -- find bundle id for Slack
    -- hs.fnutils.each(hs.application.runningApplications(), function(app) print(app:bundleID()) end)
    hs.application.launchOrFocusByBundleID("ru.keepcoder.Telegram")
    hs.application.launchOrFocusByBundleID("com.hnc.Discord")
    hs.application.launchOrFocusByBundleID("md.obsidian")
    hs.application.launchOrFocusByBundleID("com.tinyspeck.slackmacgap")
    hs.application.launchOrFocusByBundleID("com.apple.Music")
    hs.application.launchOrFocusByBundleID("com.googlecode.iterm2")

    hs.layout.apply(workAtHomeLayout)
end

hs.hotkey.bind(hyper, "1", function()
    homeLayout()
end)
