local hyper = {"cmd", "alt", "ctrl", "shift"}

-- launch obsidian and open daily note with hotkey
hs.hotkey.bind(hyper, "o", function()
    local app = hs.application.launchOrFocus("Obsidian")
    hs.eventtap.keyStroke(hyper, "d", 200000, app)
end)
