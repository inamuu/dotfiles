# Sync Skills

このskillは、Claude Code と Codex の両方で同じローカル skill を使えるように同期するときに使います。

## 対象

- Codex: `./.codex/skills`
- Claude Code: `./.claude/skills`

## 対象範囲

1. ユーザーが skill 名を指定したら、その skill だけを同期する
2. 指定がなければ、両ディレクトリ配下のローカル skills を比較して、欠けている側または古い側を同期する
3. 次は同期対象から除外する
   - `./.codex/skills/.system`
   - `./.claude/plugins`
   - `./.claude/plugins/cache`

## 正とする側の決め方

skill ごとに、次の順で正とする側を決めます。

1. ユーザーが「Claude側で作った」「Codex側を正にして」などと明示したら、その指示を優先する
2. 片側にしか存在しないなら、その存在する側を正とする
3. 両側にあり内容が実質同じなら何もしない
4. 両側にあり内容が違うなら、関連ファイルの更新時刻を比較して新しい側を正とする
5. 更新時刻でも判断しにくい、または上書きリスクが高いなら、どちらを優先するかユーザーに確認する

## 形式変換ルール

- Codex 側は必ず `SKILL.md` にする
  - `name` と `description` の frontmatter を付ける
- Claude 側は、既存 skill があるなら元の形式を維持する
  - `skill.json` + `prompt.md`
  - `skill.md`
  - `SKILL.md`
- Claude 側に新規作成するなら、`skill.json` + `prompt.md` を作る

## 変換方法

- Claude `skill.json` + `prompt.md` -> Codex
  - `name` と `description` は `skill.json`
  - 本文は `prompt.md`
- Claude `skill.md` / `SKILL.md` -> Codex
  - metadata がなければ folder 名を `name` に使う
  - `description` が無ければ、最初の説明文から短く要約して補う
  - 本文はそのまま使う
- Codex -> Claude
  - Codex frontmatter の後ろの本文を Claude 側本文として使う
  - Claude 側を新規作成する場合は、同じ `name` と `description` を `skill.json` に入れる

## 実行手順

1. 両側の対象 skill を読む
2. skill ごとに正とする側を決める
3. 反対側を作成または更新する
4. 同期のための補助スクリプトは使わず、ファイルを直接読んで直接編集する
5. 元の skill の言語とトーンはなるべく維持する
6. 作成・更新したファイルを短く報告する

## 応答

- 基本は日本語で返答する
- 報告は短く、どの files を触ったか明示する
