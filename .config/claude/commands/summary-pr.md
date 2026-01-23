# Overview

これは、PullRequestを作成する際に使用するカスタムコマンドです

This is a custom command for create a pull request overview

## Commands

1. `git diff $(git remote show origin | grep "HEAD branch" | awk '{print $3}')..HEAD` を実行して、今のブランチの変更内容を把握する
2. 変更点のサマリーを作成して、markdownとして出力する
  - 出力フォーマットは下記とする
  - サマリーは長すぎない様に、最大でも10行程度にする
  - 説明は簡潔にする
  - 説明は丁寧語ではなく、断定的にする。例. XXXを追加した、YYYを削除した、ZZZを抑制する
  - 変更ファイルの記載は不要

## 禁止事項

1. 文章のあとにコロンを記載しない
  - 例. XXXを追加: 

## Output format

in Japanese.

```
## 変更内容

{内容を1行で説明}

## 詳細

{変更内容の詳細を数行程度で説明}

```
