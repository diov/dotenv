---
name: git-workflow
description: 用户的 Git 工作流规则。在提交、开分支或 worktree、合并、整理历史、推送、删除分支或 worktree 之前读取；任务收尾清理时也读取。
---

# Git 工作流

用户级 `AGENTS.md` 的「Git」一节只留了随时生效的几条，其余在这里。项目级 `AGENTS.md` 有不同规定时以项目级为准。

## 分支与 worktree

- 多个 session 可能共用一个目录：默认在主目录开分支，做完切回原分支；主目录不在 main 或有别人未提交的改动时，不切它的分支，改开 worktree。
- 在一个项目里第一次开 worktree 前，先查有哪些不进 git 的必需文件（数据、密钥、`local.properties`），在项目级 `AGENTS.md` 里写明怎么带过去。

## 提交

- 按 scope 拆原子 commit，一个 commit 一个意图；文档/schema 变更与实现分开提交。
- 开发分支上照常这样提交，不为 log 整洁提前合并。
- 不改 `.gitignore` 的跟踪策略（如 `task_plan.md` 是故意跟踪的）。

## 合并

- 合并方式（squash / fast-forward）由项目级 `AGENTS.md` 声明；没声明时先问用户，问完写进项目级 `AGENTS.md`。
- 轻流程：给出 diff 摘要，确认后按项目的合并方式直接合并；Codex review 和整理历史只在用户要求时做。
- 重流程：合并回 main 前先对整个分支跑 Codex review（`--base main`），结果按必须修 / 低风险 / 误报分类给用户，修完再合并。

## 整理历史（fast-forward 合并的项目，重流程）

squash 合并的项目跳过这一节。

1. 合并同一主题的文档小改、实验记录、修正前一个 commit 的 commit，保留"规范 → 实现"的先后。
2. 在新分支上重建，不改动原分支。
3. 用 `git diff` 确认新旧分支内容完全一致，再 fast-forward 合并。
4. 整理后的 commit 列表写在总结里，不用等用户确认；原分支随后直接删除（内容已确认一致）。

改写已推送的历史、或从历史里删除内容时，先给出 commit 列表等用户确认。

## 收尾

任务结束时删掉自己开的 worktree 和临时文件，停掉自己起的后台进程。确需保留的，在最后的回复里写出路径和原因。

已合并的分支连同它的 worktree 直接删，本地和远程都删，不用问。"已合并"的判定：

- fast-forward 合并的项目：`git fetch` 后分支最新 commit 是 `origin/<main>` 的祖先。
- 其他项目以 GitHub 为准：分支对应的 PR 状态是 merged，且分支最新 commit 等于该 PR 合并时的 head commit 或其祖先，或与之 `git diff` 为空。squash 合并后 git 自己认不出，`branch -d` 会拒绝，比对过才用 `-D`。

不满足上述条件的（没有 PR、PR 未合并、分支在 PR 合并后还有新 commit），先打 `archive/<分支名>` tag，再问用户删不删。
