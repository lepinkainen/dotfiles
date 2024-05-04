local rectangleKey = {"alt", "ctrl"}

-- Check if the window is currently docked to the right half
function isRightHalfOld(win, screen)
    local f = win:frame()
    local max = screen:frame()
    return f.x == max.x + (max.w / 2) and f.y == max.y and f.w == max.w / 2 and
               f.h == max.h
end

function isRightHalf(win, screen)
    local f = win:frame()
    local max = screen:frame()
    return f.x + f.w == max.x + max.w
end

-- Find the next screen to the right of the current one
function nextScreen(screen)
    local screens = hs.screen.allScreens()
    for s = 1, #screens do
        if screens[s]:id() == screen:id() then
            return screens[(s % #screens) + 1]
        end
    end
end

-- Check if the window is currently docked to the left half
function isLeftHalf(win, screen)
    local f = win:frame()
    local max = screen:frame()
    return f.x == max.x and f.y == max.y and f.w == max.w / 2 and f.h == max.h
end

-- Find the previous screen to the left of the current one
function prevScreen(screen)
    local screens = hs.screen.allScreens()
    for s = 1, #screens do
        if screens[s]:id() == screen:id() then
            return screens[(s == 1 and #screens or s - 1)]
        end
    end
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
function resize(key, frameFunc)
    hs.hotkey.bind(rectangleKey, key, function()
        local win = hs.window.focusedWindow()
        local screen = win:screen()
        local max = screen:frame()
        frameFunc(win, max)
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
frames.left = function(win, max)
    local screen = win:screen()
    if isLeftHalf(win, screen) then
        local prev = prevScreen(screen)
        if prev then
            setWindowFrame(win, prev:frame().x + prev:frame().w / 2,
                           prev:frame().y, prev:frame().w / 2, prev:frame().h)
        end
    else
        setWindowFrame(win, max.x, max.y, max.w / 2, max.h)
    end
end

frames.right = function(win, max)
    local screen = win:screen()
    if isRightHalf(win, screen) then
        local next = nextScreen(screen)
        if next then
            setWindowFrame(win, next:frame().x, next:frame().y,
                           next:frame().w / 2, next:frame().h)
        end
    else
        setWindowFrame(win, max.x + max.w / 2, max.y, max.w / 2, max.h)
    end
end

-- Bind keys to frame functions
for key, frame in pairs(frames) do resize(key, frame) end
