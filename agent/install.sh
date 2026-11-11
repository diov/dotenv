#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/common.sh"

link "$DOTENV/agent/AGENTS.md" "$HOME/.claude/CLAUDE.md"
link "$DOTENV/agent/AGENTS.md" "$HOME/.codex/AGENTS.md"
link "$DOTENV/agent/claude-code-only.md" "$HOME/.claude/claude-code-only.md"
link "$DOTENV/agent/claude-settings.json" "$HOME/.claude/settings.json"
link "$DOTENV/agent/skills/git-workflow" "$HOME/.claude/skills/git-workflow"
link "$DOTENV/agent/skills/git-workflow" "$HOME/.codex/skills/git-workflow"

if ! command -v rtk >/dev/null; then
  echo "error: rtk not found, run brew/install.sh first" >&2
  exit 1
fi
# The Claude Code rtk hook already lives in claude-settings.json; only Codex needs init.
rtk init -g --codex
