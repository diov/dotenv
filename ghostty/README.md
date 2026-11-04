Ghostty terminal config, plus `ghostty-toggle`, a background helper that shows and hides Ghostty with `cmd+escape`.

### Install

```bash
./install.sh
```

- Links `config.ghostty` → `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty`.
- Builds `ghostty-toggle.swift` into `~/.local/bin/ghostty-toggle` (needs the Xcode Command Line Tools), writes the LaunchAgent `~/Library/LaunchAgents/local.ghostty-toggle.plist` and (re)loads it.

Ghostty loads this macOS path after `~/.config/ghostty/`, so keep only one of them to avoid silent overrides.

### Why ghostty-toggle

Ghostty's own `keybind = global:cmd+escape=toggle_visibility` shows the window but cannot hide it: while Ghostty is frontmost, `cmd+escape` never reaches its keybinding handling (other keys such as `ctrl+grave_accent` work). See [discussion #11255](https://github.com/ghostty-org/ghostty/discussions/11255). So `config.ghostty` binds no global key, and the helper owns `cmd+escape`.

To stop it:

```bash
launchctl bootout "gui/$(id -u)/local.ghostty-toggle"
```
