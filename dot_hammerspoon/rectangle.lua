-- Replicate basic Rectangle functionality of moving windows
local rectangleKey = {"alt", "ctrl"}

-- Function to set window position and size
function setWindowFrame(win, x, y, w, h)
    local f = win:frame()
    f.x = x
    f.y = y
    f.w = w
    f.h = h
    win:setFrame(f, 0)
end

-- Left half of the screen
hs.hotkey.bind(rectangleKey, "left", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    setWindowFrame(win, max.x, max.y, max.w / 2, max.h)
end)

-- Right half of the screen
hs.hotkey.bind(rectangleKey, "right", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    setWindowFrame(win, max.x + (max.w / 2), max.y, max.w / 2, max.h)
end)

-- Full screen
hs.hotkey.bind(rectangleKey, "Return", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    setWindowFrame(win, max.x, max.y, max.w, max.h)
end)

-- Top half of the screen
hs.hotkey.bind(rectangleKey, "up", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    setWindowFrame(win, max.x, max.y, max.w, max.h / 2)
end)

-- Bottom half of the screen
hs.hotkey.bind(rectangleKey, "down", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    setWindowFrame(win, max.x, max.y + max.h / 2, max.w, max.h / 2)
end)

-- Top right quarter
hs.hotkey.bind(rectangleKey, "i", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    setWindowFrame(win, max.x + max.w / 2, max.y, max.w / 2, max.h / 2)
end)

-- Top left quarter
hs.hotkey.bind(rectangleKey, "u", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    setWindowFrame(win, max.x, max.y, max.w / 2, max.h / 2)
end)

-- Bottom left quarter
hs.hotkey.bind(rectangleKey, "j", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    setWindowFrame(win, max.x, max.y + max.h / 2, max.w / 2, max.h / 2)
end)

-- Bottom right quarter
hs.hotkey.bind(rectangleKey, "k", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    setWindowFrame(win, max.x + max.w / 2, max.y + max.h / 2, max.w / 2,
                   max.h / 2)
end)

-- Thirds (left)
hs.hotkey.bind(rectangleKey, "d", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = max.x
    f.y = max.y
    f.w = max.w / 3
    f.h = max.h
    win:setFrame(f, 0)
end)

-- Thirds (middle)
hs.hotkey.bind(rectangleKey, "f", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = max.x + (max.w / 3)
    f.y = max.y
    f.w = max.w / 3
    f.h = max.h
    win:setFrame(f, 0)
end)

-- Thirds (right)
hs.hotkey.bind(rectangleKey, "g", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = max.x + 2 * (max.w / 3)
    f.y = max.y
    f.w = max.w / 3
    f.h = max.h
    win:setFrame(f, 0)
end)
