// Personal global actions. Keep IDs stable: KDE stores overrides against them.
(function () {
    "use strict";

    var HYPER = "Ctrl+Alt+Shift+Meta";
    var pendingFocus = null;

    function matchesApplication(win, app) {
        return !win.specialWindow &&
            (String(win.desktopFileName).toLowerCase() === app.desktopFile.toLowerCase() ||
             String(win.resourceClass).toLowerCase() === app.resourceClass.toLowerCase());
    }

    function activate(win) {
        win.minimized = false;
        workspace.activeWindow = win;
    }

    function focusApplication(app) {
        var windows = workspace.windowList().filter(function (win) {
            return matchesApplication(win, app);
        });
        // Prefer the requested vault when multiple Obsidian windows exist.
        windows.sort(function (a, b) {
            var aPreferred = app.caption && a.caption.indexOf(app.caption) >= 0;
            var bPreferred = app.caption && b.caption.indexOf(app.caption) >= 0;
            return Number(bPreferred) - Number(aPreferred) || b.stackingOrder - a.stackingOrder;
        });
        if (!windows.length) return false;
        activate(windows[0]);
        return true;
    }

    workspace.windowAdded.connect(function (win) {
        if (!pendingFocus) return;
        if (Date.now() > pendingFocus.expires) {
            pendingFocus = null;
        } else if (matchesApplication(win, pendingFocus.app)) {
            pendingFocus = null;
            activate(win);
        }
    });

    function launchAndFocus(unit, app) {
        // Explicit KWin activation also works when the URI is handled in the background.
        pendingFocus = focusApplication(app) ? null : {app: app, expires: Date.now() + 15000};
        startService(unit);
    }

    // Start an on-demand user service; no shell commands run inside KWin.
    function startService(unit) {
        callDBus("org.freedesktop.systemd1", "/org/freedesktop/systemd1",
            "org.freedesktop.systemd1.Manager", "StartUnit", unit, "replace");
    }

    // Add future actions here. A run callback can also use callDBus or workspace.
    var shortcuts = [
        {
            id: "ObsidianDailyNote",
            title: "Open Obsidian daily note",
            key: HYPER + "+O",
            run: function () {
                launchAndFocus("obsidian-daily-note.service", {
                    desktopFile: "md.obsidian.Obsidian",
                    resourceClass: "obsidian",
                    caption: "Obsidian Main Vault"
                });
            }
        }
    ];

    shortcuts.forEach(function (shortcut) {
        if (!registerShortcut("GlobalShortcuts" + shortcut.id,
            "Global Shortcuts: " + shortcut.title, shortcut.key, shortcut.run)) {
            print("Global Shortcuts: could not register " + shortcut.id);
        }
    });
}());
