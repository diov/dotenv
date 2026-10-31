Homebrew packages, as a hand-written whitelist.

### Install

```bash
./install.sh
```

Runs `brew bundle install --file Brewfile --no-upgrade`. It only installs what is missing; it never uninstalls or upgrades.

### Maintaining the Brewfile

- `brew install` works as usual. Packages tried out ad hoc do not need to be in the Brewfile.
- To keep a package on every machine, add a line such as `brew "xxx"` to `Brewfile` and commit it.
- Do not regenerate this file with `brew bundle dump`: the dump also lists npm, uv and cargo packages, which are managed by mise.
- `brew bundle cleanup --file Brewfile` lists installed packages that are not in the Brewfile. It asks before removing anything.

Tools that ship their own official installer (mise, rustup) are not installed through Homebrew.
