Config zsh without any frameworks.

All zsh plugins & themes are store in `$HOME/.zsh` directory.


```bash
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ~/.zsh/fast-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions.git ~/.zsh/zsh-completions
git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.zsh/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-history-substring-search.git ~/.zsh/zsh-history-substring-search
cd ~/.zsh/ && curl -O https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/lib/history.zsh
cd ~/.zsh/ && curl -O https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/lib/key-bindings.zsh

git clone https://github.com/dracula/zsh.git ~/.zsh/dracula
```

`.zshrc` and `.zshenv` should copied to `~` directory