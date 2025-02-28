local config = require("config")
local hyper = config.hyper

local log = hs.logger.new('applications', config.debug.applications and 'debug' or 'info')

-- Application launcher with hotkeys
local appHotkeys = {
    -- Obsidian with daily note shortcut
    o = {
        app = config.apps.obsidian.name,
        callback = function(app)
            if app then
                hs.timer.doAfter(0.5, function()
                    hs.eventtap.keyStroke(hyper, "d", 200000, app)
                end)
            end
        end
    },
}

-- Register all application hotkeys
for key, appConfig in pairs(appHotkeys) do
    hs.hotkey.bind(hyper, key, function()
        log.d("Launching or focusing app: " .. appConfig.app)
        local app = hs.application.launchOrFocus(appConfig.app)

        -- Run callback if defined
        if appConfig.callback then
            appConfig.callback(app)
        end
    end)
end

-- Toggle application visibility
function toggleApplication(appName)
    local app = hs.application.get(appName)
    if app then
        if app:isFrontmost() then
            app:hide()
        else
            app:activate()
        end
    else
        hs.application.launchOrFocus(appName)
    end
end

-- Window hints (like Exposé but with keyboard shortcuts)
hs.hotkey.bind(hyper, "w", function()
    hs.hints.windowHints()
end)

-- Application window switcher
hs.hotkey.bind(hyper, "tab", function()
    hs.window.switcher.nextWindow()
end)

return {
    toggleApplication = toggleApplication
}
