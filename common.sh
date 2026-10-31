# Sourced by every <module>/install.sh.

DOTENV="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install scripts run in bash, which never reads ~/.zprofile, so rebuild the PATH
# that later steps need (tools installed by brew, mise and rustup).
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$HOME/.cargo/bin:$PATH"

# link <src> <dst>: make dst a symlink to src (an absolute path in this repo).
link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"

  if [ -L "$dst" ]; then
    local current
    current="$(readlink "$dst")"
    if [ "$current" = "$src" ]; then
      echo "linked, skip: $dst"
      return
    fi
    echo "relink: $dst (was -> $current)"
  elif [ -e "$dst" ]; then
    if [ -e "$dst.backup" ] || [ -L "$dst.backup" ]; then
      echo "error: $dst.backup already exists, resolve it manually" >&2
      exit 1
    fi
    mv "$dst" "$dst.backup"
    echo "backup: $dst -> $dst.backup"
  fi

  ln -sfn "$src" "$dst"
  echo "link: $dst -> $src"
}
