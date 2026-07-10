---
name: github
description: GitHub / git 操作に関する共通ルール。worktree の作成、ブランチ操作など git 関連の作業を行うときに使用する。
---

# GitHub / git 操作の共通ルール

## worktree

- `git worktree add` で worktree を作成する際のパスは `~/worktrees/` 配下に統一すること
- ディレクトリ名は `<リポジトリ名>-<ブランチ名>` とする（ブランチ名の `/` は `-` に置換する）

```bash
# 例: repo-name の feature/foo ブランチ用 worktree
git worktree add ~/worktrees/repo-name-feature-foo feature/foo
```

- 不要になった worktree は `git worktree remove` で削除すること

## 関連スキル

- PR 作成: `pr-create`（Draft PR を作成）
- PR 要約: `pr-summary`
