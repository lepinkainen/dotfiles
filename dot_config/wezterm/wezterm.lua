-- Built with https://alexplescan.com/posts/2024/08/10/wezterm/


-- Import the wezterm module
local wezterm = require 'wezterm'
-- Creates a config object which we will be adding our config to
local config = wezterm.config_builder()

-- set path
config.set_environment_variables = {
    PATH = '/opt/homebrew/bin:' .. os.getenv('PATH')
}

local appearance = require 'appearance'
appearance.apply_to_config(config)

-- Left option is alt: opt+7 = |
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = false


-- If you're using emacs you probably wanna choose a different leader here,
-- since we're gonna be making it a bit harder to CTRL + A for jumping to
-- the start of a line
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

local function move_pane(key, direction)
    return {
        key = key,
        mods = 'LEADER',
        action = wezterm.action.ActivatePaneDirection(direction),
    }
end

config.keys = {
    -- ... add these new entries to your config.keys table
    {
        -- I'm used to tmux bindings, so am using the quotes (") key to
        -- split horizontally, and the percent (%) key to split vertically.
        key = '"',
        -- Note that instead of a key modifier mapped to a key on your keyboard
        -- like CTRL or ALT, we can use the LEADER modifier instead.
        -- This means that this binding will be invoked when you press the leader
        -- (CTRL + A), quickly followed by quotes (").
        mods = 'LEADER',
        action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
    },
    {
        key = '%',
        mods = 'LEADER',
        action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
    },
    {
        key = 'a',
        -- When we're in leader mode _and_ CTRL + A is pressed...
        mods = 'LEADER|CTRL',
        -- Actually send CTRL + A key to the terminal
        action = wezterm.action.SendKey { key = 'a', mods = 'CTRL' },
    },
    move_pane("DownArrow", "Down"),
    move_pane("UpArrow", "Up"),
    move_pane("LeftArrow", "Left"),
    move_pane("RightArrow", "Right"),

}

-- Returns our config to be evaluated. We must always do this at the bottom of this file
return config
