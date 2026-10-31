#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/common.sh"

MISE="$HOME/.local/bin/mise"

if [ ! -x "$MISE" ]; then
  curl -fsSL https://mise.run | sh
fi

link "$DOTENV/mise/global.toml" "$HOME/.config/mise/config.toml"

# Run from $HOME so only the global config applies, not the caller's project config.
(cd "$HOME" && "$MISE" install)
