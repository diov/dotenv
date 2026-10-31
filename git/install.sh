#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/common.sh"

link "$DOTENV/git/gitconfig" "$HOME/.gitconfig"
link "$DOTENV/git/ignore" "$HOME/.config/git/ignore"
