# Rectangle Shortcuts

Plasma 6 port of `dot_hammerspoon/rectangle.lua`. All shortcuts use **Ctrl+Alt**:

| Key | Placement |
| --- | --- |
| Return | Fill usable monitor area |
| Left / Right | Left / right half; repeat to cross monitors |
| Up / Down | Top / bottom half |
| U / I / J / K | Top left / top right / bottom left / bottom right |
| D / F / G | Left / middle / right third |

Monitor cycling follows horizontal position and wraps at either end. Crossing
left lands on the previous monitor's right half; crossing right lands on the
next monitor's left half. Panels are excluded. Shortcuts share a 100 ms debounce.
Window minimum sizes may prevent an application from fitting small regions.

Install this directory as `~/.local/share/kwin/scripts/rectangle`, then enable
**Rectangle Shortcuts** in System Settings → Window Management → KWin Scripts.
Shortcuts can be reassigned under System Settings → Keyboard → Shortcuts → KWin.

Only deploy this directory on Linux. No Hammerspoon application layouts are ported.
