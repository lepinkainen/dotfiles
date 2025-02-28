-- Configuration file for Hammerspoon

local config = {}

-- Key modifiers
config.hyper = { "cmd", "alt", "ctrl", "shift" }
config.rectangleKey = { "alt", "ctrl" }

-- Display names
config.displays = {
    laptopScreen = "Built-in Retina Display",
    mainDisplay = "L32p-30",
    verticalScreen = "LEN P27h-10",
    workDisplay = "LEN P32p-20"
}

-- URL settings
config.urlService = {
    endpoint = "http://localhost:8080/api/download"
}

-- Application settings
config.apps = {
    obsidian = {
        name = "Obsidian",
        dailyNoteHotkey = { "cmd", "alt", "ctrl", "shift", "d" }
    }
}

-- Debug settings
config.debug = {
    rectangle = false,
    layouts = false,
    urlstore = true,
    applications = false,
    experimental = false
}

return config
