local rectangleKey = { "alt", "ctrl" }

local log = hs.logger.new('rectangle', 'info')

-- Tolerance in pixels for window position and size
-- Window height is sometimes a pixel off preventing isRightHalf and isLeftHalf from returning true
local tolerance = 1

-- Debounce time in seconds
local debounceTime = 0.1
-- Store the time of the last function call
local lastCallTime = 0

-- Order screens based on x position left to right
-- This allows prevScreen and nextScreen to work correctly
local function getScreensOrderedLeftToRight()
    local screens = hs.screen.allScreens()
    table.sort(screens, function(a, b) return a:frame().x < b:frame().x end)
    return screens
end

-- Find the next screen to the right of the current one
local function nextScreen(screen)
    log.d("Running nextScreen function")

    local screens = getScreensOrderedLeftToRight()
    for s = 1, #screens do
        if screens[s]:id() == screen:id() then
            log.d("Found current screen at index " .. s)
            return screens[(s % #screens) + 1]
        end
    end
end

-- Find the previous screen to the left of the current one
local function prevScreen(screen)
    log.d("Running prevScreen function")

    local screens = getScreensOrderedLeftToRight()
    for s = 1, #screens do
        if screens[s]:id() == screen:id() then
            log.d("Found current screen at index " .. s)
            return screens[(s == 1 and #screens or s - 1)]
        end
    end
end


-- Check if the window is currently occupying the full screen
local function isFullScreen(win, screen)
    local f = win:frame()
    local max = screen:frame()
    return math.abs(f.x - max.x) <= tolerance and math.abs(f.y - max.y) <=
        tolerance and math.abs(f.w - max.w) <= tolerance and math.abs(
            f.h - max.h) <= tolerance
end

-- Check if the window is currently docked to the left half
local function isLeftHalf(win, screen)
    local f = win:frame()
    local max = screen:frame()
    return math.abs(f.x - max.x) <= tolerance and math.abs(f.h - max.h) <=
        tolerance
end

local function isRightHalf(win, screen)
    local f = win:frame()
    local max = screen:frame()
    return math.abs((f.x + f.w) - (max.x + max.w)) <= tolerance and
        math.abs(f.h - max.h) <= tolerance
end

-- Function to set window position and size
function setWindowFrame(win, x, y, w, h)
    local f = win:frame()
    f.x = x
    f.y = y
    f.w = w
    f.h = h
    win:setFrame(f, 0)
end

-- Function to resize frame
local function resize(key, frameFunc)
    log.d("Running resize function with key " .. key)

    hs.hotkey.bind(rectangleKey, key, function()
        local currentTime = hs.timer.secondsSinceEpoch()
        -- Only call the function if enough time has passed since the last call
        if currentTime - lastCallTime >= debounceTime then
            log.d(
                "Enough time has passed since the last call, running frameFunc")
            local win = hs.window.focusedWindow()
            local screen = win:screen()
            local max = screen:frame()
            frameFunc(win, max)
            lastCallTime = currentTime
        else
            log.d(
                "Not enough time has passed since the last call, skipping frameFunc")
        end
    end)
end

-- Frame calculation functions
local frames = {
    ["return"] = function(win, max)
        setWindowFrame(win, max.x, max.y, max.w, max.h)
    end,
    up = function(win, max)
        setWindowFrame(win, max.x, max.y, max.w, max.h / 2)
    end,
    down = function(win, max)
        setWindowFrame(win, max.x, max.y + max.h / 2, max.w, max.h / 2)
    end,
    i = function(win, max)
        setWindowFrame(win, max.x + max.w / 2, max.y, max.w / 2, max.h / 2)
    end,
    u = function(win, max)
        setWindowFrame(win, max.x, max.y, max.w / 2, max.h / 2)
    end,
    j = function(win, max)
        setWindowFrame(win, max.x, max.y + max.h / 2, max.w / 2, max.h / 2)
    end,
    k = function(win, max)
        setWindowFrame(win, max.x + max.w / 2, max.y + max.h / 2, max.w / 2,
            max.h / 2)
    end,
    d = function(win, max)
        setWindowFrame(win, max.x, max.y, max.w / 3, max.h)
    end,
    f = function(win, max)
        setWindowFrame(win, max.x + (max.w / 3), max.y, max.w / 3, max.h)
    end,
    g = function(win, max)
        setWindowFrame(win, max.x + 2 * (max.w / 3), max.y, max.w / 3, max.h)
    end
}

-- Left half and Right half functions move the window to another screen when pressed again
-- Left side needs some extra love because the right side is correctly positioned on top left after moving screens, left side is not
frames.left = function(win, max)
    local screen = win:screen()
    if isRightHalf(win, screen) then
        setWindowFrame(win, max.x, max.y, max.w / 2, max.h) -- Move to left half
    elseif isLeftHalf(win, screen) then
        local prev = prevScreen(screen)
        if prev then
            -- Move the window to the new screen first
            setWindowFrame(win, prev:frame().x + prev:frame().w / 2,
                prev:frame().y, win:frame().w, win:frame().h)
            -- Then resize it to fit the new screen
            setWindowFrame(win, prev:frame().x + prev:frame().w / 2,
                prev:frame().y, prev:frame().w / 2, prev:frame().h)
        end
    else
        setWindowFrame(win, max.x, max.y, max.w / 2, max.h)
    end
end

frames.right = function(win, max)
    local screen = win:screen()
    -- don't move the window if it's fullscreen, make it right half instead
    if isRightHalf(win, screen) and not isFullScreen(win, screen) then
        local next = nextScreen(screen)
        if next then
            -- Move the window to the new screen first
            setWindowFrame(win, next:frame().x, next:frame().y, win:frame().w,
                win:frame().h)
            -- Then resize it to fit the new screen
            setWindowFrame(win, next:frame().x, next:frame().y,
                next:frame().w / 2, next:frame().h)
        end
    else
        setWindowFrame(win, max.x + max.w / 2, max.y, max.w / 2, max.h)
    end
end

-- Bind keys to frame functions
for key, frame in pairs(frames) do resize(key, frame) end
