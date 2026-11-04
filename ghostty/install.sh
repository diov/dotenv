#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/common.sh"

link "$DOTENV/ghostty/config.ghostty" "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"

bin="$HOME/.local/bin/ghostty-toggle"
mkdir -p "$(dirname "$bin")"
swiftc -O -swift-version 5 "$DOTENV/ghostty/ghostty-toggle.swift" -o "$bin"
echo "build: $bin"

# Generated rather than linked: launchd needs the absolute binary path, which contains the user name.
label="local.ghostty-toggle"
plist="$HOME/Library/LaunchAgents/$label.plist"
mkdir -p "$(dirname "$plist")"
cat >"$plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$label</string>
  <key>ProgramArguments</key>
  <array>
    <string>$bin</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
</dict>
</plist>
EOF

# Reload so a rebuilt binary takes effect.
launchctl bootout "gui/$(id -u)/$label" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$plist"
echo "launchd: $label"
