# AGENTS.md（项目级）

## 流程档位

本仓库是个人 dotfiles，固定走轻流程，不套用用户级的重流程触发条件（改 `install.sh`、`common.sh`、`agent/` 下的规则也一样）：

- 不写计划文件，不做计划审查。
- 是否先给方案、是否 review，由 Agent 按改动大小自行判断。

## Worktree

没有不进 git 的必需文件，开 worktree 不需要额外拷贝。

## 合并方式

fast-forward 合并到 `master`，不开 PR。
