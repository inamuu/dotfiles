---
allowed-tools: Read, Glob, Grep, Bash(git:*), Bash(npm:*), Bash(ls:*), Bash(cp:*), Bash(mkdir:*), Bash(find:*), Bash(terraform:init,validate,fmt,plan)
description: "Terraformコードのレビューをします"
---

### 概要

これはカスタムコマンドの説明です。
Terraformのコードが既存コードと異なる点が無いかを確認します。

### 手順

1. 現在のブランチを確認して、現在のブランチで追加したcommitを確認します。
2. commit履歴からどのような変更をterraformに加えたかを確認します。
3. 加えられたterarformの変更で、まずterraform構文として誤りが無いかを確認します。
4. つぎに他のterraformの命名規則にあっているかを確認します。

