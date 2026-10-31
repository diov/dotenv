#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/common.sh"

if [ ! -x "$HOME/.cargo/bin/rustup" ]; then
  # PATH is already set in zsh/zprofile
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
  source "$HOME/.cargo/env"
fi

# `toolchain install` on an existing toolchain updates it, so only run it when missing.
if ! rustup toolchain list | grep -q '^stable-'; then
  rustup toolchain install --no-self-update stable
fi
rustup target add --toolchain stable x86_64-apple-darwin
