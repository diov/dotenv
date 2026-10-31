#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/common.sh"

if ! command -v brew >/dev/null; then
  echo "error: Homebrew not found. Install it first (needs sudo):" >&2
  echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"' >&2
  exit 1
fi

brew bundle install --file "$DOTENV/brew/Brewfile" --no-upgrade
