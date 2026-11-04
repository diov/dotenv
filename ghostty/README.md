Ghostty terminal config, plus `ghostty-toggle`, a temporary background helper that shows and hides Ghostty with `cmd+escape`.

### Install

```bash
./install.sh
```

- Links `config.ghostty` → `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty`.
- Builds `ghostty-toggle.swift` into `~/.local/bin/ghostty-toggle` (needs the Xcode Command Line Tools), writes the LaunchAgent `~/Library/LaunchAgents/local.ghostty-toggle.plist` and (re)loads it.

Ghostty loads this macOS path after `~/.config/ghostty/`, so keep only one of them to avoid silent overrides.

### Why ghostty-toggle (temporary workaround)

Ghostty's own `keybind = global:cmd+escape=toggle_visibility` shows the window but cannot hide it: while Ghostty is frontmost, `cmd+escape` never reaches its keybinding handling (other keys such as `ctrl+grave_accent` work). Seen on Ghostty 1.4.0, see [discussion #11255](https://github.com/ghostty-org/ghostty/discussions/11255). So `config.ghostty` binds no global key, and the helper owns `cmd+escape`.

### Removing it once Ghostty is fixed

After a Ghostty update, check whether the official binding works again: stop the helper (step 1), add the keybind (step 2), reload Ghostty, then press `cmd+escape` twice while Ghostty is frontmost. If it hides, finish the removal:

1. Unload the LaunchAgent and delete what `install.sh` generated:
   ```bash
   launchctl bootout "gui/$(id -u)/local.ghostty-toggle"
   rm ~/Library/LaunchAgents/local.ghostty-toggle.plist ~/.local/bin/ghostty-toggle
   ```
2. Add `keybind = global:cmd+escape=toggle_visibility` back to `config.ghostty`.
3. Delete `ghostty-toggle.swift`, the build and LaunchAgent part of `install.sh`, and this section.

If it still does not hide, remove that keybind again and run `./install.sh` to restore the helper.
