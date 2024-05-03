local hyper = {"cmd", "alt", "ctrl", "shift"}

-- Layouts
local verticalScreen = "LEN P27h-10"
local homeLayout = {
    {
        "Telegram", nil, verticalScreen, hs.geometry.unitrect(0, 0, 1, 0.5),
        nil, nil
    }, {
        "Discord", nil, verticalScreen, hs.geometry.unitrect(0, 0.5, 1, 0.5),
        nil, nil
    }
}

hs.hotkey.bind(hyper, "1", function()
    hs.layout.apply(homeLayout)
    hs.notify.new({
        title = "Hammerspoon",
        informativeText = "Home layout applied"
    }):send()

end)
