# 󰌌 System & Desktop Keybindings Cheatsheet

> **Quick Reference**: Press `q` or `<Esc>` to dismiss this cheatsheet.  
> Search anytime with `/query` + `<Enter>` (navigate with `n` / `N`).  
> System-wide shortcut: `Super + /` (`Mod + /`) or `Super + F1`.

---

## 1. 🚀 System Launchers & Essentials

| Shortcut | Action | Description |
|:---|:---|:---|
| `Super + Return` | **Ghostty Terminal** | Opens terminal with Fish shell |
| `Super + Space` or `Super + D` | **Noctalia Launcher** | Toggle application launcher panel |
| `Super + B` | **Firefox** | Launch web browser |
| `Super + E` | **Yazi** | Fast terminal file manager |
| `Ctrl + Shift + G` | **Gopac** | Interactive package manager |
| `Ctrl + Shift + B` | **bptui** | Bluetooth / package TUI |
| `Ctrl + Shift + M` | **Matcha** | Terminal email client |
| `Ctrl + Shift + J` | **Jellyfin TUI** | Terminal Jellyfin media client |
| `Ctrl + Shift + A` | **aichat** | Terminal AI assistant chat |
| `Ctrl + Shift + D` | **Concord** | Terminal Discord chat client |
| `Super + Alt + L` | **Lock Screen** | Lock display via Swaylock |
| `Super + Shift + C` | **Formatting Cheatsheet** | Floating Markdown, Mermaid & LaTeX reference |
| `Super + /` or `Super + F1` | **Keybindings Cheatsheet** | This floating keybinds reference |

---

## 2. 📱 Minisforum V3 Tablet & Hardware Controls

| Shortcut / Trigger | Action | Description |
|:---|:---|:---|
| `Super + Alt + R` | **Toggle Rotation Lock** | Lock/unlock auto-rotation (sends desktop notification) |
| `XF86RotationLockToggle` | **Hardware Rotate Lock** | Hardware tablet rotation lock button |
| `XF86MonBrightnessUp` | **Brightness +10%** | Increase display brightness via `brightnessctl` |
| `XF86MonBrightnessDown` | **Brightness -10%** | Decrease display brightness via `brightnessctl` |
| `Super + Shift + P` | **Power Off Displays** | Put monitors to sleep (wake on key press or touch) |
| `Super + Alt + S` | **Screen Reader** | Toggle Orca accessibility screen reader |

### 🖐️ Touchscreen Gestures (niri-tablet)
| Gesture | Action | Notes |
|:---|:---|:---|
| **3-finger horizontal drag** | **Scroll Columns** | 1:1 live animated scroll across the view |
| **3-finger vertical drag** | **Workspace Carousel** | 1:1 animated vertical workspace carousel |
| **3-finger tap** | **Maximize Column** | Toggle column maximized / normal width |
| **3-finger hold (~400ms) + swipe** | **Move Window** | Held left/right moves column; up/down moves to workspace |
| **4-finger tap** | **Overview** | Open zoomed-out window overview |
| **4-finger flick down** | **Close Window** | Close focused window |
| **4-finger flick up** | **Fullscreen Window** | Fullscreen focused window |
| **Edge swipe from Top** | **Overview** | Single-finger swipe down from top screen border |
| **Edge swipe from Left** | **Focus Left** | Single-finger swipe right from left border |
| **Edge swipe from Right** | **Focus Right** | Single-finger swipe left from right border |

---

## 3. 🔊 Audio & Media Controls

| Shortcut | Action | Description |
|:---|:---|:---|
| `XF86AudioRaiseVolume` | **Volume +10%** | Increase speaker volume (capped at 100%) |
| `XF86AudioLowerVolume` | **Volume -10%** | Decrease speaker volume |
| `XF86AudioMute` | **Mute Audio** | Toggle output mute via WirePlumber |
| `XF86AudioMicMute` | **Mute Microphone** | Toggle input microphone mute |
| `XF86AudioPlay` | **Play / Pause** | Toggle active MPRIS media playback |
| `XF86AudioStop` | **Stop Media** | Stop active media playback |
| `XF86AudioNext` | **Next Track** | Skip to next track in player |
| `XF86AudioPrev` | **Previous Track** | Return to previous track in player |

---

## 4. 🪟 Niri Window Navigation & Movement

| Shortcut | Action | Description |
|:---|:---|:---|
| `Super + Left/Right` or `H / L` | **Focus Column** | Move focus to adjacent column |
| `Super + Down/Up` or `J / K` | **Focus Window** | Move focus to window below / above in column |
| `Super + Ctrl + Left/Right` or `H / L` | **Move Column** | Move focused column left or right |
| `Super + Ctrl + Down/Up` or `J / K` | **Move Window** | Move window down or up within current column |
| `Super + Home` / `Super + End` | **First / Last Column** | Jump focus to the first or last column |
| `Super + Ctrl + Home` / `End` | **Move to Ends** | Move current column to first or last position |
| `Super + [` / `Super + ]` | **Consume / Expel** | Pull window into column or kick window out |
| `Super + ,` | **Consume into Column** | Pull window from the right to the bottom of column |
| `Super + .` | **Expel from Column** | Kick bottom window out to a new column on the right |
| `Super + Q` | **Close Window** | Close the currently focused window |
| `Super + O` | **Toggle Overview** | Open / close zoomed-out window overview |

---

## 5. 📐 Window Layout, Sizing & Floating

| Shortcut | Action | Description |
|:---|:---|:---|
| `Super + F` | **Maximize Column** | Maximize column with gaps preserved |
| `Super + Shift + F` | **Fullscreen** | Fullscreen current window (no gaps/borders) |
| `Super + M` | **Maximize to Edges** | Expand window to screen edges without gaps |
| `Super + Ctrl + F` | **Fill Width** | Expand column to fill all available workspace width |
| `Super + C` | **Center Column** | Center focused column on the display |
| `Super + Ctrl + C` | **Center All** | Center all currently visible columns |
| `Super + R` | **Cycle Width** | Cycle through preset column widths (1/3, 1/2, 2/3) |
| `Super + Shift + R` | **Cycle Width Back** | Cycle preset column widths in reverse |
| `Super + Ctrl + R` | **Reset Height** | Reset window height back to automatic |
| `Super + Ctrl + Shift + R` | **Cycle Height** | Toggle preset window heights |
| `Super + -` / `Super + =` | **Adjust Width** | Fine-tune column width by -10% / +10% |
| `Super + Shift + -` / `+ =` | **Adjust Height** | Fine-tune window height by -10% / +10% |
| `Super + V` | **Toggle Floating** | Switch window between tiled and floating mode |
| `Super + Shift + V` | **Switch Focus** | Toggle focus between floating and tiled windows |
| `Super + W` | **Tabbed Display** | Toggle vertical tabbed display in focused column |

---

## 6. 🌐 Workspaces & Multiple Monitors

| Shortcut | Action | Description |
|:---|:---|:---|
| `Super + 1 .. 9` | **Switch Workspace** | Jump directly to workspace 1 through 9 |
| `Super + Ctrl + 1 .. 9` | **Move to Workspace** | Move focused column to workspace 1 through 9 |
| `Super + Page_Down / Page_Up` or `U / I` | **Next / Prev Workspace** | Switch to adjacent workspace below / above |
| `Super + Ctrl + Page_Dn/Up` or `U / I` | **Move Column to Workspace** | Move current column to workspace below / above |
| `Super + Shift + Page_Dn/Up` or `U / I` | **Move Workspace** | Reorder the active workspace up / down |
| `Super + Shift + Left/Down/Up/Right` | **Focus Monitor** | Move focus to adjacent physical monitor |
| `Super + Shift + Ctrl + Left/Down/Up/Right` | **Move to Monitor** | Move focused column to adjacent monitor |
| `Super + MouseWheel Up / Down` | **Scroll Workspace** | Switch workspace with mouse wheel (rate-limited) |
| `Super + Ctrl + MouseWheel` | **Move with Wheel** | Move column across workspaces using wheel |
| `Super + Shift + MouseWheel` | **Horizontal Scroll** | Scroll columns horizontally across the workspace |

---

## 7. 📸 Screenshots & Session

| Shortcut | Action | Description |
|:---|:---|:---|
| `Print` or `Super + P` | **Area Screenshot** | Interactive rectangle selection screenshot |
| `Ctrl + Print` or `Super + Ctrl + P` | **Full Screen** | Capture entire display output |
| `Alt + Print` or `Super + Alt + P` | **Window Screen** | Capture only the focused window |
| `Super + Escape` | **Inhibitor Toggle** | Toggle shortcut inhibitor (for VMs / remote desktop) |
| `Super + Shift + E` | **Quit Niri** | Exit Niri session (shows confirmation modal) |
| `Ctrl + Alt + Delete` | **Quit Niri** | Emergency exit confirmation modal |

---

## 8. 🎨 Noctalia Shell & Matugen IPC Commands

| Command | Action / Purpose |
|:---|:---|
| `noctalia msg panel-toggle launcher` | Toggle main Noctalia application launcher |
| `noctalia msg settings-toggle` | Open or close Noctalia desktop settings |
| `noctalia msg theme-mode-toggle` | Instantly toggle Matugen theme between Dark & Light |
| `noctalia msg wallpaper-random` | Cycle to next random wallpaper and re-theme system |
| `noctalia msg notification-dnd-toggle` | Toggle Do-Not-Disturb notification status |
| `noctalia msg notification-clear-active` | Dismiss all active on-screen notification popups |
| `noctalia msg window-switcher` | Open Noctalia interactive window switcher |
