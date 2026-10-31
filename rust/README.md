Rust via [rustup](https://rustup.rs).

### Install

```bash
./install.sh
```

The script:

1. Installs rustup with the official script if `~/.cargo/bin/rustup` is missing. It passes `--no-modify-path` because PATH is set in `zsh/zprofile`.
2. Ensures the `stable` toolchain and the `x86_64-apple-darwin` target exist.

Existing toolchains are not updated. Run `rustup update` yourself.
