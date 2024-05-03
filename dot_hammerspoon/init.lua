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

-- launch obsidian and open daily note with hotkey
hs.hotkey.bind(hyper, "o", function()
    local app = hs.application.launchOrFocus("Obsidian")
    hs.eventtap.keyStroke({"shift", "cmd"}, "d", 200000, app)
end)

require("rectangle")
require("layouts")
