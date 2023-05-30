Config zsh without any frameworks.

### Install plugins & themes

All zsh plugins & themes are store in `$HOME/.zsh` directory.


```bash
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ~/.zsh/fast-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions.git ~/.zsh/zsh-completions
git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.zsh/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-history-substring-search.git ~/.zsh/zsh-history-substring-search
git clone --depth 1 https://github.com/marlonrichert/zsh-edit.git ~/.zsh/zsh-edit
cd ~/.zsh/ && curl -O https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/lib/history.zsh
cd ~/.zsh/ && curl -O https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/lib/key-bindings.zsh

git clone https://github.com/dracula/zsh.git ~/.zsh/dracula
```

### Setup

```bash
ln -fs $(pwd)/zshrc ~/.zshrc
ln -fs $(pwd)/zshenv ~/.zshenv
ln -fs $(pwd)zprofile ~/.zprofile
```
