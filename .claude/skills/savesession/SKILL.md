---
name: savesession
description: 現在のClaude Codeセッションを、翌日以降に追加指示なしで再開できる「引き継ぎファイル」として保存する。保存したセッションはシェルの ccr コマンドで fzf から選んで再開できる。「セッションを保存して」「続きは明日」「再開できるようにして」「引き継ぎを残して」と頼まれたとき、および /savesession と入力されたときに使用する。作業記録（Actaデイリーノート）が目的なら savedata を使う。
argument-hint: "[done | 保存先パス]"
---

# savesession - 再開用の引き継ぎファイル保存

セッションの状態を、次の Claude Code がこのファイルだけ読めば作業を再開できる形で保存する。
再開はシェルで `ccr` を実行し、fzf で選ぶ（`~/.config/zsh/functions/claude_session.zsh`）。

## 保存先

```
${HOME}/Google Drive/マイドライブ/LLM/ClaudeCode/Sessions/<yyyy-mm-dd>-<slug>.md
```

- `slug` は作業内容を表す英小文字とハイフンの短い名前（例: `herdr-esc-delay`）
- パスは必ず `$HOME` から解決し、空白を含むのでダブルクォートで囲む
- Google Drive で同期されるため git の commit / push は不要
- 引数でパスまたはディレクトリが指定された場合はそこに保存する
- 既存の引き継ぎファイルから再開したセッション（最初のプロンプトに `ClaudeCode/Sessions/...md` のパスがある）では、新規作成せず同じファイルを上書き更新する
- 引数が `done` の場合は、再開元の引き継ぎファイルの `status` を `done` に変えるだけで終了する（ccr の一覧から消える）

## 手順

1. 情報を集める

   ```bash
   date "+%Y-%m-%d %H:%M"; pwd
   git rev-parse --show-toplevel 2>/dev/null && git branch --show-current && git status --short
   ```

   - セッション ID は `${CLAUDE_SESSION_ID}`
   - `repo` は git ルートの `~/ghq/` からの相対パス（例: `github.com/inamuu/dotfiles`）。ghq 管理外なら空

2. 下記フォーマットで引き継ぎファイルを書く（ディレクトリが無ければ `mkdir -p`）
3. 保存先パスと「`ccr` で再開できる」ことを 1〜2 行で報告する

## フォーマット

```markdown
---
title: <作業タイトル（日本語、ccr の一覧に出る）>
status: open
updated: yyyy-mm-dd HH:MM
cwd: <作業ディレクトリの絶対パス>
repo: <ghq 相対パス or 空>
branch: <ブランチ名 or 空>
session_id: <セッション ID>
---

# <作業タイトル>

## ゴール

<このセッション群で最終的に達成したいこと>

## 現状

<どこまで終わったか。完了した作業、変更したファイル、作成した PR など>

## 次にやること

1. <再開直後に最初にやる具体的な作業。コマンドやファイルパスまで書く>
2. ...

## 決定事項・前提

<決めた方針、ユーザーの好み・制約、却下した案とその理由>

## 未解決・注意点

<詰まっている点、確認待ち、未コミットの変更、触ってはいけないもの>

## 参照

<重要なファイルパス（file:line）、URL、ログ、コマンド>
```

## 書き方の注意

- 読み手は会話履歴を持たない次の Claude。「さっきの」「例の」など文脈依存の表現は使わず、固有名詞・パス・コマンドで書く
- 「次にやること」は最優先。そのまま着手できる粒度で書く
- 未コミットの変更がある場合は `未解決・注意点` に明記する
- シークレット（トークン、パスワード、APIキー等）は記録しない
- 出力は日本語、絵文字なし
