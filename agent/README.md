User-level rules and settings for coding agents.

### Install

```bash
./install.sh
```

Links:

| File | Target |
|---|---|
| `AGENTS.md` | `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md` |
| `claude-code-only.md` | `~/.claude/claude-code-only.md` |
| `claude-settings.json` | `~/.claude/settings.json` |

Then the script runs `rtk init -g --codex` to generate `~/.codex/RTK.md` and the Codex hook. rtk must already be installed by `brew/install.sh`. The Claude Code rtk hook is already in `claude-settings.json`.

### Notes

- `AGENTS.md` is shared by Claude Code and Codex. Claude Code does not read a user-level `AGENTS.md`, so it is linked as `~/.claude/CLAUDE.md`. Rules for Claude Code only go in `claude-code-only.md`, which `AGENTS.md` imports with `@~/...`. Codex does not expand `@` imports.
- Claude Code writes `/config` changes into `claude-settings.json` through the link, so commit them like any other change.
- This repo is public. Never put API keys in `claude-settings.json`.
- `~/.codex/config.toml` is not tracked because it contains secrets.
- Plugins listed in `claude-settings.json` may need `/plugin install` on a new machine (unverified).
