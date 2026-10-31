Config zsh without any frameworks.

### Install

```bash
./install.sh
```

The script:

1. Clones the theme and plugins into `~/.zsh` if missing:
   - [dracula/zsh](https://github.com/dracula/zsh)
   - [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting)
   - [zsh-completions](https://github.com/zsh-users/zsh-completions)
   - [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
   - [zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search)
   - [zsh-edit](https://github.com/marlonrichert/zsh-edit)
2. Downloads `history.zsh` and `key-bindings.zsh` from oh-my-zsh into `~/.zsh` if missing.
3. Links `zshrc`, `zshenv` and `zprofile` to `~/.zshrc`, `~/.zshenv` and `~/.zprofile`.

Existing plugins are not updated.

### PATH

All PATH setup lives in `zprofile`. `~/.local/bin` comes right after Homebrew; mise is activated after that.
