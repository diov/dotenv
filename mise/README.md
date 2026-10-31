[mise](https://mise.jdx.dev) manages language runtimes and global CLI tools.

### Install

```bash
./install.sh
```

The script:

1. Installs mise into `~/.local/bin` with the official installer (`curl -fsSL https://mise.run | sh`) if missing.
2. Links `global.toml` to `~/.config/mise/config.toml`.
3. Runs `mise install` from `$HOME`, so only the global config is used.

The file is named `global.toml` rather than `config.toml` because mise treats `<dir>/mise/config.toml` as a project config.

### What it manages

- Languages: Go, Node, Python, Java (Temurin 17), Bun, Deno, pnpm, uv.
- Global CLI tools: `npm:` and `pypi:` entries. They do not depend on the active Node or Python version.
  - Add one with `mise use -g npm:<package>`. Do not use `npm install -g`.
- Python for uv: `UV_PYTHON` points uv at mise's Python, so uv does not download its own interpreters.
- `JAVA_HOME` is set by mise. Do not export it in `zprofile`, or that value overrides mise's.

### Known issues

- GUI apps launched from the Dock do not see mise's `JAVA_HOME`, and `/usr/libexec/java_home` finds no JDK. If an app needs it, link mise's JDK into the system location (rerun after every JDK upgrade, since the path contains the version):

  ```bash
  JDK="$(mise where java)"
  sudo mkdir "/Library/Java/JavaVirtualMachines/$(basename "$JDK").jdk"
  sudo ln -s "$JDK/Contents" "/Library/Java/JavaVirtualMachines/$(basename "$JDK").jdk/Contents"
  ```

- `npm:@mermaid-js/mermaid-cli` is pinned to `11.12.0`. Version 12.x depends on `chromium-bidi` 157+, which is published without npm provenance (10.4.0 had it), so mise's trust policy rejects the install. Unpin when newer `chromium-bidi` releases carry provenance again. Alternatively, after reviewing the publisher, add the exact `chromium-bidi@<version>` to the tool's `trust_policy_excludes`.
