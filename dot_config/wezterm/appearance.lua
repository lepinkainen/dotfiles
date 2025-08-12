local wezterm = require 'wezterm'

local module = {}

local function get_git_branch()
    local handle = io.popen("git branch --show-current 2>/dev/null")
    if not handle then
        return nil
    end

    local branch = handle:read("*a")
    handle:close()

    if not branch or branch == "" then
        return nil
    end

    branch = branch:gsub("\n", "")
    return "󰊢 " .. branch
end


function module.apply_to_config(config)
    --config.color_scheme = 'Default Dark (base16)'
    --config.color_scheme = 'Dark Pastel'
    -- https://github.com/kepano/flexoki
    config.color_scheme = 'Flexoki Dark'

    -- Choose your favourite font, make sure it's installed on your machine
    config.font = wezterm.font 'Fira Code'
    -- And a font size that won't have you squinting
    config.font_size = 13

    -- Slightly transparent and blurred background
    config.window_background_opacity = 0.9
    config.macos_window_background_blur = 30

    -- Removes the title bar, leaving only the tab bar. Keeps
    -- the ability to resize by dragging the window's edges.
    -- On macOS, 'RESIZE|INTEGRATED_BUTTONS' also looks nice if
    -- you want to keep the window controls visible and integrate
    -- them into the tab bar.
    config.window_decorations = 'RESIZE|INTEGRATED_BUTTONS'

    config.window_frame = {
        -- Berkeley Mono for me again, though an idea could be to try a
        -- serif font here instead of monospace for a nicer look?
        font = wezterm.font({ family = 'Fira Code', weight = 'Bold' }),
        font_size = 14,
    }

    local function segments_for_right_status(window)
        local domain_name = window:active_pane():get_domain_name()
        local workspace = window:active_workspace()
        local segments = {}

        -- Only add workspace if it's not "default"
        if workspace ~= "default" then
            table.insert(segments, workspace)
        end

        -- Git branch (if available)
        local git_branch = get_git_branch()
        if git_branch then
            table.insert(segments, git_branch)
        end


        local cwd = window:active_pane():get_current_working_dir()
        if cwd then
            local basename = cwd.file_path:match("([^/]+)/?$")
            table.insert(segments, "📁 " .. (basename or "~"))
        end


        table.insert(segments, wezterm.strftime('%a %Y-%m-%d %H:%M'))
        table.insert(segments, domain_name)

        return segments
    end

    wezterm.on('update-status', function(window, _)
        local SOLID_LEFT_ARROW = utf8.char(0xe0b2)
        local segments = segments_for_right_status(window)

        local color_scheme = window:effective_config().resolved_palette
        -- Note the use of wezterm.color.parse here, this returns
        -- a Color object, which comes with functionality for lightening
        -- or darkening the colour (amongst other things).
        local bg = wezterm.color.parse(color_scheme.background)
        local fg = color_scheme.foreground

        -- Each powerline segment is going to be coloured progressively
        -- darker/lighter depending on whether we're on a dark/light colour
        -- scheme. Let's establish the "from" and "to" bounds of our gradient.
        local gradient_to, gradient_from = bg
        gradient_from = gradient_to:lighten(0.2)

        -- Yes, WezTerm supports creating gradients, because why not?! Although
        -- they'd usually be used for setting high fidelity gradients on your terminal's
        -- background, we'll use them here to give us a sample of the powerline segment
        -- colours we need.
        local gradient = wezterm.color.gradient(
            {
                orientation = 'Horizontal',
                colors = { gradient_from, gradient_to },
            },
            #segments -- only gives us as many colours as we have segments.
        )

        -- We'll build up the elements to send to wezterm.format in this table.
        local elements = {}

        for i, seg in ipairs(segments) do
            local is_first = i == 1

            if is_first then
                table.insert(elements, { Background = { Color = 'none' } })
            end
            table.insert(elements, { Foreground = { Color = gradient[i] } })
            table.insert(elements, { Text = SOLID_LEFT_ARROW })

            table.insert(elements, { Foreground = { Color = fg } })
            table.insert(elements, { Background = { Color = gradient[i] } })
            table.insert(elements, { Text = ' ' .. seg .. ' ' })
        end

        window:set_right_status(wezterm.format(elements))
    end)
end

return module
