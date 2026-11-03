#!/usr/bin/env bash
set -euo pipefail

DOTENV="$(cd "$(dirname "$0")" && pwd)"

for module in brew zsh git ghostty mise rust agent; do
  echo "==> $module"
  bash "$DOTENV/$module/install.sh"
done
