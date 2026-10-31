# dotenv：补齐模块并提供安装脚本

## 背景

dotenv 用于跨设备配置 macOS 环境（仓库是 public）。目前只有 zsh 进了版本管理且以软链接安装；mise、Rust、git、agent 用户级规则、Homebrew 包列表都只存在于本机。语言与全局 CLI 工具的管理也比较分散：Python 有 4 个来源，npm 全局包绑定在某个 Node 版本上，Java 是手动装的 `.pkg`。

已决定不再使用：hammerspoon（本机已卸载）、vim 配置、Flutter、parakeet-mlx、opencode-antigravity-auth、firebase、cargo-udeps。

## 目标

1. 删除 hammerspoon、vim 模块，删除 Flutter 相关配置及本机环境。
2. 修正 zsh 的 PATH：去重、去掉写死的 `/Users/dio.ye`、删除不再需要的行。
3. 新增 brew、mise、rust、git、agent 模块，每个模块目录下有幂等的 `install.sh`。
4. 根目录 `install.sh` 一键按顺序安装所有模块。
5. mise 成为语言版本（含 Java、Python）和全局 CLI 工具的唯一来源。
6. 删除两个跨 agent 协作 skill（`planning-to-file`、`executing-file-plan`）及其本机软链接。

## 范围与前提

- 仅支持 Apple Silicon macOS（`zprofile` 写死了 `/opt/homebrew`）。
- 新设备的前置条件：已手动安装 Homebrew；已配置 GitHub SSH key（`gitconfig` 会把 `https://github.com/diov/` 改写成 SSH）。
- 安装方式的原则：自带官方安装脚本的工具（mise、rustup）用官方脚本安装，不走 brew；brew 只装其余少量命令行工具。
- “唯一来源”的范围：仅指“语言与全局工具的归属”表中列出的语言和 6 个全局 CLI。`~/.local/bin` 下各自用官方安装器装的 `claude`、`agy`、`duckdb` 不纳入，在根 README 中列为“新设备手动安装”。
- 不做：Android SDK 不纳入（由 Android Studio 管理）；`zprofile` 中 Android 路径在新设备上不存在时不做处理；Claude Code plugins 在新设备上是否需要手动 `/plugin install`（未验证，写进 agent README 的“已知事项”）。
- 公开仓库约束：不跟踪任何含密钥的文件；README 提醒不要往 `claude-settings.json` 的 `env` 里写 API key。

## 完成标准（幂等的定义）

在本机连续执行两次根目录 `install.sh`，两次退出码都是 0。执行方式模拟新设备的最小环境，并从仓库以外的目录调用：`cd /tmp && env -i HOME="$HOME" PATH=/usr/bin:/bin bash <repo>/install.sh`。第二次满足：
- 链接映射表中的每个目标都是指向仓库文件的软链接，且输出均为“已链接，跳过”；
- 没有产生新的 `.backup`；
- 仓库 `git status --short` 与执行前的输出一致（比较前后状态，不要求仓库绝对干净）。

软件的安装与版本、缓存、日志不在判定范围内。安装不做升级：brew 使用 `--no-upgrade`，`mise install` 只安装缺失的工具，rustup 已存在时不执行 `rustup update`。

## 思路

- 每个模块自包含：配置文件 + `install.sh`，安装方式是把仓库文件软链接到目标路径。
- 共用 `common.sh`，只提供 `link <src> <dst>`，规则见下。
- 根 `install.sh` 只负责按依赖顺序调用各模块脚本：brew → zsh → git → mise → rust → agent。

**被否决的备选**：
- GNU stow / chezmoi：需引入第三方依赖，而总共只有十来个链接，`ln -sfn` 足够。
- 全局 CLI 用各生态自己的方式安装（`npm -g`、`uv tool`），不依赖 mise：`npm -g` 绑定 Node 版本，升级就丢；mise 已废弃 `~/.default-npm-packages`（2026.11.0 起警告，2027.11.0 停止读取）[已验证 via https://mise.jdx.dev/lang/node.html]；而且全局工具会分成两套表示。依赖 mise 的代价：以后换管理器时要重写约 6 行工具清单。

**复用**：
- `zsh/README.md` 中的插件、主题 clone 命令。
- Homebrew 官方 `brew bundle install --file <path> --no-upgrade` [已验证 via `brew bundle --help` 与 Homebrew 源码 `bundle/subcommand/install.rb`]。显式传 `--file`，不链接 `~/.Brewfile`，也不依赖 `--global` 的路径解析规则。
- rustup 官方生成的 `~/.cargo/env`（安装后在当前进程加载 PATH）。
- `settings.json` 中已有的 `rtk hook claude`。
- mise 的 `npm:` / `pypi:` 后端；mise 的 Java 支持会设置 `JAVA_HOME`；`UV_PYTHON` 可让 uv 使用 mise 的 Python [已验证 via https://mise.jdx.dev/lang/java.html、https://mise.jdx.dev/lang/python.html、https://mise.jdx.dev/dev-tools/backends/pypi.html]。

### `link <src> <dst>` 规则

src 一律使用仓库文件的绝对路径；“指向 src”的判断为 `readlink dst` 的文本等于该绝对路径。

1. 先 `mkdir -p "$(dirname dst)"`。
2. dst 是软链接且指向 src：打印“已链接”，跳过。
3. dst 是软链接但指向别处或已悬空：打印旧目标，用 `ln -sfn` 替换（只是链接，不会丢数据）。本机的 `~/.codex/AGENTS.md → ~/.claude/CLAUDE.md` 走这一支。
4. dst 是普通文件或目录：`<dst>.backup` 已存在则报错退出，不覆盖；否则移到 `<dst>.backup` 后再链接。
5. dst 不存在：直接链接。

### 脚本约定

- 可以在任意 cwd 下执行（脚本先解析自身所在目录）；每个模块脚本都能单独执行。
- `#!/usr/bin/env bash` + `set -euo pipefail`，兼容 macOS 自带的 bash 3.2；任何一步失败都以非 0 退出。
- PATH 统一由 `common.sh` 建立，每个模块脚本 source 它，所以单独执行时也一样。bash 脚本不会加载 `.zprofile`，因此在 `common.sh` 中：`/opt/homebrew/bin/brew` 存在时执行 `brew shellenv`，然后把 `$HOME/.local/bin`、`$HOME/.local/share/mise/shims`、`$HOME/.cargo/bin` 前置到 PATH（目录不存在也无害）。
- 模块里刚安装完的命令，在同一进程中这样调用：mise 用 `$HOME/.local/bin/mise` 绝对路径；rustup 安装后 `source "$HOME/.cargo/env"`。
- 模块依赖前提：缺少依赖命令时打印“请先运行 `<模块>/install.sh`”并 `exit 1`。具体依赖：agent 依赖 `rtk`（brew 模块）；mise 的 `pypi:` 工具依赖 uv，由 mise 自己安装。
- 未安装 Homebrew 时，brew 脚本打印官方安装命令后 `exit 1`（安装需要 sudo 交互，不自动执行）。
- 临时测试目录统一放在 Claude Code session 的 scratchpad 中，任务结束时删除。

## 目录结构（完成后）

```
install.sh            # one-click, calls modules in order
common.sh             # link() helper
README.md
task_plan.md
brew/   Brewfile, install.sh, README.md
zsh/    zshrc, zprofile, zshenv, install.sh, README.md
git/    gitconfig, ignore, install.sh, README.md
mise/   global.toml, install.sh, README.md   # not config.toml: <dir>/mise/config.toml is a mise project config path
rust/   install.sh, README.md
agent/  CLAUDE.md, claude-code-only.md, claude-settings.json, install.sh, README.md
handbrake/  H265(VideoToolbox).json      # unchanged, no install script; import via HandBrake GUI
```

## 链接映射表

| 仓库文件 | 目标 |
|---|---|
| `zsh/zshrc` / `zprofile` / `zshenv` | `~/.zshrc` / `~/.zprofile` / `~/.zshenv` |
| `git/gitconfig` | `~/.gitconfig` |
| `git/ignore` | `~/.config/git/ignore` |
| `mise/global.toml` | `~/.config/mise/config.toml` |
| `agent/CLAUDE.md` | `~/.claude/CLAUDE.md` 和 `~/.codex/AGENTS.md` |
| `agent/claude-code-only.md` | `~/.claude/claude-code-only.md` |
| `agent/claude-settings.json` | `~/.claude/settings.json` |

不跟踪的文件：
- `~/.codex/config.toml`：含明文 API key、本机 trust 列表和本地代理地址。
- `~/.codex/RTK.md`、`~/.codex/hooks.json`：由 `rtk init -g --codex` 生成。
- `~/.claude/RTK.md`：当前没有任何文件引用它（`CLAUDE.md` 引用的是 Codex 那份），保持原样，不处理。
- `~/.zsh/` 下的插件、缓存、历史：由 zsh 脚本 clone/下载，不链接。

## 语言与全局工具的归属（目标状态）

| 项目 | 管理方 | 说明 |
|---|---|---|
| Go、Node、Python、Bun、Deno、pnpm、uv | mise | 版本沿用现有配置 |
| Java | mise：`java = "temurin-17"` | 删除 `zprofile` 的 `JAVA_HOME` export，否则会覆盖 mise 的值 |
| 全局 CLI | mise：`"npm:@openai/codex"`、`"npm:pyright"`、`"npm:@mermaid-js/mermaid-cli"`、`"npm:@binance/agentic-wallet"`、`"pypi:ruff"`、`"pypi:git-filter-repo"`，版本均为 `latest` | 迁移前先记录现有版本，便于对比 |
| uv 使用的 Python | mise | `[env] UV_PYTHON = { value = "{{ tools.python.path }}", tools = true }`；`python.uv_venv_auto` 从已废弃的 `true` 改为 `"create|source"`（`true` 的含义是 `create|source` 加导出 `UV_PYTHON`，改为 `UV_PYTHON` 配方后行为一致） |
| Rust | rustup（官方脚本） | stable + `x86_64-apple-darwin` target |
| Homebrew | tap `homebrew/services`；`coreutils ffmpeg gh imagemagick rtk zsh` | Brewfile 是**手写白名单**，不是 `brew bundle dump` 的快照（dump 默认还会收集 npm/uv/cargo 条目，会和 mise 重复）。`git-filter-repo` 移入 mise 后，brew 的 `python@3.13` 失去唯一的依赖方，用 `brew autoremove` 清掉。本机的 `webp` 也标记为手动安装（`installed_on_request`），默认不列入白名单，也不卸载 |
| 系统 Python 3.9.6 | Xcode CLT | 不动，PATH 中排在最后 |

## RTK 的处理（已用 dry-run 实测）

- **Claude 侧**：不执行 `rtk init`。hook 已在 `claude-settings.json` 中（`rtk -v init -g --hook-only --no-patch --dry-run` 输出 “hook already present”）。不执行普通的 `rtk init -g`，因为它会往 `CLAUDE.md` 里加 `@RTK.md`。
- **Codex 侧**：执行 `rtk init -g --codex`。`--codex` 不能和 `--auto-patch`、`--no-patch` 一起用。dry-run 输出 “RTK.md already up to date / reference already present in AGENTS.md / Nothing written”，在本机是幂等的。
- `agent/CLAUDE.md` 中的 `@/Users/dio.ye/.codex/RTK.md` 这一行由 rtk 生成、归 rtk 管：保持原样，不改成 `@~/`，否则 rtk 认不出来会再追加一行。用户名不同的设备上 rtk 会追加一行新的绝对路径，属于已知事项，写进 README。

## 实施步骤

分支：在主目录 `git switch -c feat/install-scripts`，带上当前未提交的 zsh 改动和未跟踪的 `agent/`。`agent/skills/` 从未提交过，直接删除即可，不产生删除 commit。

规则：每个 commit 一个意图；先写文档（规范）再实现，实现与文档有出入时在最后回头同步。每一步完成后更新本文件中的状态。本机删除一律用 `/usr/bin/trash`（进废纸篓可恢复）。唯一的例外是第 6 步删除旧 JDK：需要 sudo，且是不可恢复的 `rm -rf`，列出命令由我执行。

### 0. `docs: add install scripts plan` — 状态：完成
- 提交本文件。

### 1. `docs: describe modules and install contract` — 状态：完成
- 新增根 `README.md`：范围与前提、模块列表、`./install.sh` 用法、链接规则摘要、语言与工具归属、未跟踪文件、handbrake 手动导入、新设备手动安装的工具（`claude`、`agy`、`duckdb`）、Brewfile 维护方式（手写白名单：要长期保留的包先加到 `brew/Brewfile`，再运行 `brew/install.sh`）、已知事项（rtk 绝对路径、Claude plugins、不要往 settings `env` 写密钥）。
- 各模块 README 改为指向 `./install.sh`，删除手写的 `ln` 命令。新模块（brew/git/mise/rust/agent）的 README 在这里一并创建。

### 2. `chore: remove hammerspoon, vim and flutter configs` — 状态：完成
- `git rm -r hammerspoon vim`；`zprofile` 删除 Flutter PATH 行。
- 本机清理：`~/.vim/vimrc`；`~/Project/Environment/flutter`、`~/Project/Environment/firebase`；`~/.config/flutter`、`~/.config/firebase`；以及存在的 `~/.pub-cache`、`~/.flutter`、`~/.dart-tool`、`~/.dartServer`（先列出再删）。`~/Project/Environment` 如果变成空目录也一并删除。
- 验证：
  - `git diff --cached --stat` 只包含这两个目录和 `zprofile`；
  - `vim --not-a-term -c 'redir! > <scratchpad>/vim.txt' -c scriptnames -c 'redir END' -c q` 的输出包含 `defaults.vim`；
  - 新 shell 中 `command -v flutter` 为空。

### 3. `fix(zsh): dedupe PATH and drop hardcoded home path` — 状态：完成
- 保留已有的全部未提交改动：Android 改用 `cmdline-tools/latest` 并加上 `emulator`、删除旧的 `~/.antigravity` PATH、注释掉 `ksh_option_print`。
- `zshrc`：删除末尾 Antigravity 安装器追加的 PATH 行。
- `zprofile`：
  - `export PATH="$HOME/.local/bin:$PATH"` 移到 Homebrew 之后、mise 之前，删除末尾的重复行；
  - mise 行改为 `eval "$(mise activate zsh)"`，mise 由 `~/.local/bin` 提供；
  - Golang 两行改为 `export PATH="$PATH:$HOME/go/bin"`，不再在启动时调用 `go env`（GOPATH 未自定义，就是默认的 `~/go`）。
- 验证：`zsh -lic 'print -l $path' | grep -c '/.local/bin$'` 输出 1；新 shell 里 `mise --version`、`go version` 正常；`zsh -lic exit` 无报错输出。

### 4. `feat(zsh): add link helper and install script` — 状态：完成
- 新增 `common.sh`（`link()`）。
- 新增 `zsh/install.sh`：Dracula 主题和 5 个插件的目录不存在时 clone，`history.zsh`、`key-bindings.zsh` 不存在时下载（命令取自 `zsh/README.md`），然后链接三个文件。
- 验证：
  - `bash -n`；本机连续执行两次，均输出“已链接，跳过”；
  - `link()` 的分支 3、4、5 在 scratchpad 里用临时目标路径各测一次（悬空链接、普通文件、已存在 `.backup`、不存在的父目录）；
  - 用 `HOME=<scratchpad>/home` 跑一次 `zsh/install.sh`，覆盖首次 clone。

### 5. `feat(brew): add Brewfile and install script` — 状态：完成
- 手写 `brew/Brewfile`，内容只有归属表中的 1 个 tap 和 6 个 formula。
- `brew/install.sh`：检查 Homebrew；执行 `brew bundle install --file "<repo>/brew/Brewfile" --no-upgrade`。
- 验证：`brew bundle check --file brew/Brewfile` 通过；再次执行 `brew/install.sh` 不安装任何东西；`git diff brew/` 为空（安装不会写这个文件）。

### 6. `feat(mise): manage java, python and global CLIs via mise` — 状态：完成
- `mise/global.toml`：以本机 `~/.config/mise/config.toml` 为基础，按“语言与全局工具的归属”表加入 `java`、6 个全局 CLI、`[env] UV_PYTHON`，并改 `python.uv_venv_auto`。文件名不用 `config.toml`：mise 会把 `<目录>/mise/config.toml` 识别为该目录的项目配置，在 dotenv 仓库里会被重复加载。
- `zprofile`：删除 `export JAVA_HOME=...`。
- `mise/install.sh`：
  - 找不到 `$HOME/.local/bin/mise` 时执行官方安装命令 `curl -fsSL https://mise.run | sh` [已验证 via https://mise.jdx.dev/getting-started.html]；
  - 链接配置；
  - 执行 `(cd "$HOME" && "$HOME/.local/bin/mise" install)`。固定在 `$HOME` 下执行，只读全局配置，不受调用者当前所在项目的配置影响。
- 本机迁移，按顺序执行，每一项做完都验证。原则是先建新的、验证通过，再删旧的：
  1. 记录现状：`npm ls -g --depth=0`、`uv tool list`、`java -version`、`brew list git-filter-repo`。
  2. 运行 `mise/install.sh`。在 `$HOME` 下开新 shell 验证：
     - `command -v codex pyright mmdc baw ruff git-filter-repo` 都指向 mise 的路径（`baw` 是 `@binance/agentic-wallet` 的命令名），各自 `--version` 或 `--help` 能正常运行；
     - `java -version` 为 Temurin 17，`echo $JAVA_HOME` 指向 mise 的 JDK；
     - `uv python find` 指向 mise 的 Python。
  3. 重建基于 uv 自带 Python 3.14.2 的项目 venv，此时旧解释器还在，失败可回退。涉及 `fleet_server_standalone`（`>=3.10`）、`finance-hub`（`>=3.14.2`）、`ASRTour`（`>=3.12`），都位于 `~/Project/SideProject/`，mise 的 3.14.2 均满足。在各目录先把 `.venv` 移到废纸篓，再执行 `uv sync --locked`：锁文件需要变化时直接报错，不会改写。执行后确认 `.venv/pyvenv.cfg` 的 `home` 指向 mise 的 Python，三个项目的 `git status --short` 与执行前一致。任何一个失败就停下，从废纸篓恢复 `.venv`，回来找我。
  4. 卸载旧的全局工具：`npm uninstall -g @openai/codex pyright @mermaid-js/mermaid-cli @binance/agentic-wallet opencode-antigravity-auth`；`uv tool uninstall ruff parakeet-mlx`；`brew uninstall git-filter-repo && brew autoremove`，确认 `python@3.13` 被移除。
  5. 清理 uv 自带的 Python（实施中发现还有 uv 全局版本文件 `~/.config/uv/.python-version`，它会让 `uv python find` 优先选 uv 自己的 Python，一并删除）：`/usr/bin/trash ~/.local/bin/python ~/.local/bin/python3 ~/.local/bin/python3.14`；`uv python uninstall --all`。之后三个项目里 `uv run python -V` 仍正常。
  6. 列出 sudo 命令由我执行，删除旧 JDK：`sudo rm -rf /Library/Java/JavaVirtualMachines/temurin-17.jdk`。执行后 `/usr/libexec/java_home -V` 不再列出它，新 shell 中 `java -version` 仍正常。
- 验证：
  - 在 `$HOME` 下执行 `mise ls`，config 来源为 `~/.config/mise/config.toml`；
  - `mise doctor` 无 deprecation 警告；
  - 执行 `mise use -g bun@latest`（与现有内容相同的写入）后仍是软链接，且 `git diff mise/` 为空。

### 7. `feat(rust): add rustup install script` — 状态：完成
- `rust/install.sh`：
  - 找不到 `$HOME/.cargo/bin/rustup` 时，执行官方脚本 `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path`（PATH 已在 `zprofile` 中，实现时以官方文档核对参数），然后 `source "$HOME/.cargo/env"`；
  - 执行 `rustup toolchain install stable` 和 `rustup target add --toolchain stable x86_64-apple-darwin`，两者在已安装时都是空操作，不受项目 override 影响。
- 本机：`cargo uninstall cargo-udeps`。
- 验证：本机执行两次，第二次无安装动作；`rustup show` 中 targets 不变。

### 8. `feat(git): track gitconfig and global ignore` — 状态：完成
- 拷入 `~/.gitconfig`、`~/.config/git/ignore`；`git/install.sh` 链接两者。
- 验证：`git config --global user.email` 输出不变；在 scratchpad 里 `git init` 一个仓库，`git check-ignore -v .claude/settings.local.json` 命中 `~/.config/git/ignore`。

### 9. `feat(agent): track user-level agent rules and Claude settings` — 状态：完成
- 本机清理：删除 `agent/skills/`，以及软链接 `~/.claude/skills/planning-to-file`、`~/.codex/skills/executing-file-plan`、`~/.copilot/skills/executing-file-plan`。
- 拷入 `~/.claude/CLAUDE.md`、`~/.claude/claude-code-only.md`。`CLAUDE.md` 中的 `@/Users/dio.ye/.claude/claude-code-only.md` 改为 `@~/.claude/claude-code-only.md`（home 路径 import 已验证 via https://code.claude.com/docs/en/memory）。不用相对路径：相对路径按包含 import 的文件解析，经软链接后指向哪里不确定。RTK 那一行不动。
- `claude-code-only.md` 中“`~/.codex/AGENTS.md` 是 `~/.claude/CLAUDE.md` 的软链接”这句，改为两者都链接到 dotenv 仓库的 `agent/CLAUDE.md`。
- 把 `~/.claude/settings.json` 拷成 `agent/claude-settings.json`，删除整个 `autoMode` 键（内容是单个本机项目的环境描述），其他键原样保留。
- `agent/install.sh`：执行映射表中 agent 的 4 个链接；执行 `rtk init -g --codex`。
- 验证：
  - 安装前 `rtk -v init -g --codex --dry-run` 输出 “Nothing written”；安装后 `git status agent/` 干净；
  - `readlink ~/.codex/AGENTS.md` 指向仓库；
  - 在 Claude Code 里用 `/config` 切换一次 theme 再切回，之后 `readlink ~/.claude/settings.json` 仍指向仓库，`git diff agent/` 为空（需我手动操作）；
  - 新开 Claude Code 和 Codex session 都能读到规则，Claude 里 `/memory` 能看到 `claude-code-only.md` 被导入。
- 第 6、9 步的写入测试中，若任何工具把软链接替换成了普通文件：停下，恢复链接，回来和我讨论替代方案（例如环境变量指向仓库路径）。

### 10. `feat: add one-click root installer` — 状态：完成
- 根 `install.sh`：依次调用 `brew zsh git mise rust agent` 的 `install.sh`，任一步失败即停止。PATH 由各模块 source 的 `common.sh` 建立，根脚本不额外处理。
- 验证：按“完成标准”在本机连续执行两次（最小 PATH、仓库外的 cwd）。另外，在最小 PATH 下单独执行一次 `agent/install.sh`，确认能找到 `rtk`。

### 11. `docs: sync docs with implementation` — 状态：完成（README 与实现一致，只同步了本计划的状态）
- 回扫第 1 步的 README 与实际实现是否一致。

## 实施记录

- 第 5 步：`brew bundle check` 默认把“有新版本”也算作不满足，验证时须加 `--no-upgrade`。本机的 libtiff 与 webp 之间有循环依赖警告，来自本机 Homebrew 过期的依赖记录，与本计划无关。
- 第 6 步：`npm:@mermaid-js/mermaid-cli@latest`（12.0.0）被 mise 的供应链 trust policy 拒绝。原因是其间接依赖 `chromium-bidi` 从 157.x 起由 `chrome-devtools-npm@google.com` 发布，没有 npm provenance，而 10.4.0 曾由 GitHub Actions 带 provenance 发布。未绕过检查，暂时锁定为 11.12.0。
- 第 6 步：`uv python find` 不受 `UV_PYTHON` 影响（它优先读版本文件），改用 `uv venv`、`uv sync`、`uv run` 验证。
- 第 7 步：第一版脚本对已存在的 stable 执行了 `rustup toolchain install stable`，这等同于 `rustup update stable`，把本机 stable 升级到了 1.99.1，rustup 自身也升级到了 1.29.2，违反了“不升级”的约定。已改为 stable 不存在时才安装，并加上 `--no-self-update`；修复后验证 toolchain 未再被改动。
- 第 9 步：`rtk init -g --codex` 在本机是幂等的，仓库文件未被改动。
- 第 9 步验证时发现，`CLAUDE.md` 中 `审查：@~/.claude/claude-code-only.md` 这一行的引用从未被展开（改为 `@~/` 之前的绝对路径写法也一样）：`@` 紧跟在全角冒号后面，不会被识别为 import。在 `@` 前加空格后，`/memory` 中出现了该文件 [已验证 via 新 session 的 `/memory`]。

## 收尾

- 列出执行过程中产生的所有 `.backup` 文件，由我确认后再删除，不自动删。
- 合并前对分支跑 Codex review（`--base master`），按“必须修 / 低风险 / 误报”分类。
- 合并前整理 commit 历史，按用户级 CLAUDE.md 的 Git 规则执行。

## 下一步

全部完成：手动验证均已通过（旧 JDK 已删除；`/config` 写入后 `settings.json` 仍是软链接；Claude Code 和 Codex 的新 session 都能读到规则）。剩下的是合并到 master 和收尾清理。

---

## 附：Codex 零上下文审查记录

### 第一轮（第一版计划）

**必须修（均已修改进上文）**
- 链接冲突策略未定义（异向/悬空链接、已存在 `.backup`、父目录）→ 补充 `link()` 规则。
- `rtk init -g --codex --auto-patch` 无法执行；Claude 侧 rtk 会往 `CLAUDE.md` 加 `@RTK.md` → 重新设计 RTK 的处理并用 dry-run 实测。
- `~/.codex/AGENTS.md` 已是异向链接 → 由 `link()` 分支 3 覆盖。
- 跨设备前提（`/opt/homebrew`、`java_home`、Android、Flutter）未闭合 → 写明“范围与前提”；Java 改由 mise 管理，Flutter 已删除。
- mise 迁移时机、Brewfile 范围、安装是否升级、RTK 修改归属未定 → mise 改为官方脚本独立安装；Brewfile 内容已定；完成标准排除升级；RTK 那一行归 rtk 管。
- “幂等 / 无变化”没有判定标准 → 新增“完成标准”。

**低风险（已修改）**
- 脚本运行约定（cwd、单独执行、退出码、后续模块的 PATH）→ 新增“脚本约定”。
- 写入测试的具体操作和还原方式 → 第 5/6/9 步写明命令。
- 已有 zsh 改动的归属 → 第 3 步逐项列出。
- 第 1 步 `git status` 判定不成立 → 改用 `git diff --cached --stat`。
- `rtk ... --dry-run -v` 参数位置错误 → 改为 `rtk -v init ...`。
- 文档先行 → README 移到第 1 步，最后加同步步骤。
- Dracula 主题、首次 clone 未覆盖 → 第 4 步补上，并用临时 HOME 测试。
- git ignore、vim `defaults.vim` 的验证不足 → 第 2/8 步补充。

**误报**
- Codex 自己指出：`--base master` 正确；不能断言 `brew bundle dump` 会破坏软链接。

### 第二轮（第三版计划）

**必须修（均已修改进上文）**
- 首次安装时，新装的 mise、rustup 在当前 bash 进程里找不到（bash 不加载 `.zprofile`）→ PATH 统一由 `common.sh` 建立；同一进程中 mise 用绝对路径调用，rustup 装完 `source ~/.cargo/env`；明确各模块的依赖前提。
- `mise install` 受调用者 cwd 下的项目配置影响；`mise/config.toml` 本身会被 mise 识别为 dotenv 目录的项目配置 → 固定在 `$HOME` 下执行；仓库文件改名为 `mise/global.toml`。
- Brewfile 是白名单还是快照没说清；dump 会收集 npm/uv/cargo 条目，写入测试还会把已迁走的工具写回去 → 改为手写白名单，显式传 `--file`，取消 `~/.Brewfile` 链接和 dump 写入测试。`webp` 默认不列入白名单。
- venv 重建用 `uv sync` 可能改写锁文件，且原计划先删旧 Python 再重建 → 改用 `uv sync --locked`，并调整为先重建、验证通过，再删旧 Python。
- “唯一来源”的范围不明确（`claude`、`agy`、`duckdb`、brew 的 `gh`/`rtk`）→ 在“范围与前提”中限定。
- 应复用 `~/.cargo/env`；mise 官方安装命令是 `curl -fsSL` → 已修改。

**低风险（已修改）**
- rustup 的 target 不一定加到 stable 上 → 显式写 `--toolchain stable`。
- 最小 PATH、仓库外 cwd、单独执行模块的验收场景 → 加入“完成标准”和第 10 步。
- `git status` 的比较基线、scratchpad 由谁清理 → 改为比较执行前后；scratchpad 在任务结束时删除。
- 链接“指向 src”的比较口径 → 绝对路径，比较 `readlink` 文本。
- `claude-code-only.md` 中描述的链接关系会过时 → 第 9 步同步修改。
- 遗漏了 `@binance/agentic-wallet` 的命令名 `baw` → 加入第 6 步验证。
- `brew bundle --global` 的路径解析不止两个环境变量 → 改为显式 `--file`，不再依赖它。
- “删除一律 trash”与 `sudo rm -rf` 不一致 → 明确写为唯一例外。

**误报**
- `--base master` 正确；Brewfile 软链接写入问题已随方案变更消失；RTK 在本机幂等；Python 版本约束和 `UV_PYTHON` 配方与本机、官方文档一致。
