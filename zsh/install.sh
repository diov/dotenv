#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/common.sh"

ZSH_DIR="$HOME/.zsh"
mkdir -p "$ZSH_DIR"

# clone <url> <name> [git clone args...]
clone() {
  local url="$1" dir="$ZSH_DIR/$2"
  shift 2
  if [ -d "$dir" ]; then
    echo "exists, skip: $dir"
  else
    git clone "$@" "$url" "$dir"
  fi
}

clone https://github.com/dracula/zsh.git dracula
clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git fast-syntax-highlighting
clone https://github.com/zsh-users/zsh-completions.git zsh-completions
clone https://github.com/zsh-users/zsh-autosuggestions.git zsh-autosuggestions
clone https://github.com/zsh-users/zsh-history-substring-search.git zsh-history-substring-search
clone https://github.com/marlonrichert/zsh-edit.git zsh-edit --depth 1

for f in history.zsh key-bindings.zsh; do
  if [ -f "$ZSH_DIR/$f" ]; then
    echo "exists, skip: $ZSH_DIR/$f"
  else
    # Download to a temp file first: an interrupted download must not look installed on rerun.
    curl -fsSL -o "$ZSH_DIR/$f.tmp" "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/lib/$f"
    mv "$ZSH_DIR/$f.tmp" "$ZSH_DIR/$f"
  fi
done

link "$DOTENV/zsh/zshrc" "$HOME/.zshrc"
link "$DOTENV/zsh/zshenv" "$HOME/.zshenv"
link "$DOTENV/zsh/zprofile" "$HOME/.zprofile"
