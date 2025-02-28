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

-- Network configurations for location detection
config.networks = {
    home = {
        ssids = { "Rocinante-5G" },
        machine = "mimic"
    },
    work = {
        ssids = { "Metacore" },
        machine = "mystique"
    }
}

-- Layout configurations
config.layouts = {
    -- Define which applications to launch for each layout
    apps = {
        common = {
            "md.obsidian",
            "com.apple.Music",
            "ru.keepcoder.Telegram",
            "com.hnc.Discord",
            "com.github.wez.wezterm"
        },
        home = {
            "com.irCCloud.desktop"
        },
        work = {
            "com.tinyspeck.slackmacgap"
        }
    }
}

-- URL settings
config.urlService = {
    endpoint = "http://localhost:8080/api/download"
}

-- Application settings
config.apps = {
    obsidian = {
        name = "Obsidian",
        bundleID = "md.obsidian",
        dailyNoteHotkey = { "cmd", "alt", "ctrl", "shift", "d" }
    },
    telegram = {
        name = "Telegram",
        bundleID = "ru.keepcoder.Telegram"
    },
    discord = {
        name = "Discord",
        bundleID = "com.hnc.Discord"
    },
    slack = {
        name = "Slack",
        bundleID = "com.tinyspeck.slackmacgap"
    },
    music = {
        name = "Music",
        bundleID = "com.apple.Music"
    },
    wezterm = {
        name = "WezTerm",
        bundleID = "com.github.wez.wezterm"
    },
    irccloud = {
        name = "IRCCloud",
        bundleID = "com.irCCloud.desktop"
    }
}

-- Debug settings
config.debug = {
    rectangle = false,
    layouts = false,
    urlstore = true,
    applications = false,
    experimental = false,
    location = true
}

return config
