// Port of dot_hammerspoon/rectangle.lua for Plasma 6 / Wayland.
(function () {
    "use strict";

    var tolerance = 1;
    var lastCallTime = 0;

    function area(output) {
        return workspace.clientArea(KWin.MaximizeArea, output, workspace.currentDesktop);
    }

    // Round boundaries rather than widths so odd-sized screens have no gaps.
    function rectangle(bounds, x, y, width, height) {
        var left = Math.round(bounds.x + bounds.width * x);
        var top = Math.round(bounds.y + bounds.height * y);
        return {
            x: left,
            y: top,
            width: Math.round(bounds.x + bounds.width * (x + width)) - left,
            height: Math.round(bounds.y + bounds.height * (y + height)) - top
        };
    }

    function matches(frame, target) {
        return ["x", "y", "width", "height"].every(function (key) {
            return Math.abs(frame[key] - target[key]) <= tolerance;
        });
    }

    function adjacentOutput(output, direction) {
        var outputs = Array.prototype.slice.call(workspace.screens);
        outputs.sort(function (a, b) {
            return a.geometry.x - b.geometry.x || a.geometry.y - b.geometry.y;
        });
        var index = outputs.indexOf(output);
        if (index < 0 || !outputs.length) return output;
        return outputs[(index + direction + outputs.length) % outputs.length];
    }

    function snap(win, output, target) {
        // Release fullscreen, maximization and custom tiling before setting geometry.
        win.fullScreen = false;
        win.setMaximize(false, false);
        win.tile = null;
        if (win.output !== output) workspace.sendClientToScreen(win, output);
        win.frameGeometry = target;
    }

    function bind(name, key, action) {
        registerShortcut("Rectangle" + name, "Rectangle: " + name,
            "Ctrl+Alt+" + key, function () {
                var now = Date.now();
                if (now - lastCallTime < 100) return;
                var win = workspace.activeWindow;
                if (!win || win.specialWindow || !win.resizeable) return;
                lastCallTime = now;
                action(win, win.output, area(win.output));
            });
    }

    function bindFraction(name, key, x, y, width, height) {
        bind(name, key, function (win, output, bounds) {
            snap(win, output, rectangle(bounds, x, y, width, height));
        });
    }

    bindFraction("Maximize", "Return", 0, 0, 1, 1);
    bindFraction("Top Half", "Up", 0, 0, 1, 0.5);
    bindFraction("Bottom Half", "Down", 0, 0.5, 1, 0.5);
    bindFraction("Top Left", "U", 0, 0, 0.5, 0.5);
    bindFraction("Top Right", "I", 0.5, 0, 0.5, 0.5);
    bindFraction("Bottom Left", "J", 0, 0.5, 0.5, 0.5);
    bindFraction("Bottom Right", "K", 0.5, 0.5, 0.5, 0.5);
    bindFraction("Left Third", "D", 0, 0, 1 / 3, 1);
    bindFraction("Middle Third", "F", 1 / 3, 0, 1 / 3, 1);
    bindFraction("Right Third", "G", 2 / 3, 0, 1 / 3, 1);

    bind("Left Half", "Left", function (win, output, bounds) {
        var x = 0;
        if (matches(win.frameGeometry, rectangle(bounds, 0, 0, 0.5, 1))) {
            output = adjacentOutput(output, -1);
            bounds = area(output);
            x = 0.5;
        }
        snap(win, output, rectangle(bounds, x, 0, 0.5, 1));
    });

    bind("Right Half", "Right", function (win, output, bounds) {
        var x = 0.5;
        if (matches(win.frameGeometry, rectangle(bounds, 0.5, 0, 0.5, 1))) {
            output = adjacentOutput(output, 1);
            bounds = area(output);
            x = 0;
        }
        snap(win, output, rectangle(bounds, x, 0, 0.5, 1));
    });
}());
