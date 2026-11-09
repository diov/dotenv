# 仅 Claude Code 适用的规则

`~/.claude/CLAUDE.md` 与 `~/.codex/AGENTS.md` 都是 dotenv 仓库 `agent/AGENTS.md` 的软链接（Claude Code 不读用户级 AGENTS.md，所以链成 CLAUDE.md），Codex 也会读这份规则；只给 Claude Code 的规则放在这里，由 AGENTS.md 用 `@` 引用（Codex 不展开 `@` 引用）。

- 计划文件交给我确认前，先让 Codex 以零上下文审一遍（`codex exec -s read-only --ephemeral -o <scratchpad 文件>`，后台运行，只读回 `-o` 的结果）。只给它计划文件路径，要求：先用自己的话复述方案（复述不出的部分算 blocker），再列出留给实现者自己拍板的决定、没定义或没链接的概念、计划没提到但可复用的现有代码（要实际搜代码）。结果按必须修 / 低风险 / 误报分类附在计划后；纯表述问题先改进计划再给我，设计取舍留给我定。只有重流程写计划文件，轻流程不走这一步；Codex 不可用时告诉我，不自动改用 subagent。
