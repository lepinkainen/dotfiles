# Global Shortcuts

Personal Plasma 6 global actions, alongside the separate Rectangle window script.

| Shortcut | Action |
| --- | --- |
| Hyper+O (Ctrl+Alt+Shift+Meta+O) | Open or create today's Obsidian daily note |

Hyper is the four modifiers, independent of which physical key produces them.
The daily-note action uses Obsidian's built-in `daily` URI, preserving the vault's
date format, folder, and template. The Daily notes core plugin must be enabled.
KWin explicitly restores and activates the Obsidian window, preferring the main
vault when multiple windows exist. If Obsidian is starting, the next matching
window is activated within a 15-second launch window.

## Install

Deploy this directory to `~/.local/share/kwin/scripts/global-shortcuts` and
`obsidian-daily-note.service` from the dotfiles to `~/.config/systemd/user/`.
Run `systemctl --user daemon-reload`, then enable **Global Shortcuts** under
System Settings → Window Management → KWin Scripts. The service runs on demand
and does not need enabling at login.

Reassign shortcuts under System Settings → Keyboard → Shortcuts → KWin.
KDE retains overrides, so changing a default in JavaScript may not change an
already assigned shortcut.

## Add actions

Add an entry to the `shortcuts` array in `contents/code/main.js` with a stable
`id`, a descriptive `title`, a `key` such as `HYPER + "+U"`, and a `run` callback.
Keep existing IDs stable to preserve user shortcut assignments.

For an application or command, add a named systemd user oneshot service and use
`startService("your-action.service")` in the callback. For KDE/window actions,
the callback can directly use `callDBus` or KWin's `workspace` API. Port each Mac
action deliberately: application identifiers and macOS APIs do not carry over.
Use `launchAndFocus(unit, {desktopFile: "app.id", resourceClass: "app-class"})`
to also restore and focus an application. An optional `caption` selects a
preferred window by title when the application has several windows.

Use `%%` for a literal percent in systemd unit commands (for example URI `%20`
becomes `%%20`). Reload the user manager after editing units. Disable/re-enable
the KWin script after editing JavaScript to reload shortcut registrations.

Inspect launch errors with `journalctl --user -u obsidian-daily-note.service`.
Disable **Global Shortcuts** in KWin Scripts to stop registering these bindings.
