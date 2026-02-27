# Daily Tasks (Acta)

このコマンドは、Acta の前日 `ToDo_Medley` タスクを本日分へ引き継いで整形するための専用コマンドです。

## 対象ディレクトリ
`/Users/kazuma.inamura/ghq/github.com/inamuu/data/Acta/`

## 目的
1. 前日の `ToDo_Medley` を今日の日付でコピーする
2. 完了済みタスクを削除する
3. 「追加したいタスクはありますか？」と確認し、指示があれば追記する
4. Acta 既存フォーマットを維持する

## 実行手順
1. 日本時間（`Asia/Tokyo`）で今日と前日の日付を取得する
  - `today_ymd`: `YYYY-MM-DD`
  - `today_compact`: `YYYYMMDD`
  - `yesterday_ymd`: `YYYY-MM-DD`
2. `yesterday_ymd.md` を開き、最新の `tags: ToDo_Medley` かつ `# Tasks:` を含む `<!-- acta:comment -->` ブロックを抽出する
  - 前日ファイルが存在しない場合は、`today_ymd` より前の最新日付ファイルを 1 つ探して同条件で抽出する
3. 抽出した `# Tasks: XXXXXXXX` を `# Tasks: {today_compact}` に置き換える
4. 完了済みタスクを削除する
  - 削除対象: 行中に `- [x]` を含むタスク行のみ
  - 継続対象: `- [ ]`, `- [/]`, `- [R]`, `- [R ]` のタスク行
  - `- [X]` は削除しない
  - 子タスク削除後に配下が空になった見出し行（例: `- その他`）は削除する
5. 今日のファイルを更新する
  - ファイル: `/Users/kazuma.inamura/ghq/github.com/inamuu/data/Acta/{today_ymd}.md`
  - ファイルがない場合は、先頭に `# {today_ymd}` を作成してから追記する
  - `tags: ToDo_Medley` の `acta:comment` ブロックとして保存する
  - メタデータ
    - `id`: UUID v4
    - `created`: `YYYY-MM-DD HH:MM`
    - `created_ms`: Unix timestamp (milliseconds)
    - `tags`: `ToDo_Medley`
6. 保存後、必ず次の質問をユーザーに返す
  - `追加したいタスクはありますか？`
7. ユーザーが `XXを追加して` と回答した場合
  - 直前に作成した本日分 `ToDo_Medley` ブロックの `# Tasks: {today_compact}` 配下に追加する
  - 追加先は `- その他` セクション直下
  - `- その他` が無い場合は末尾に作成してから追加する
  - 追加形式: `- [ ] XX`
8. 追加結果を短く報告して終了する

## 出力ルール
- 返答は日本語
- 変更したファイルパスと実施内容を短く示す
- Markdown のインデント・記法は、抽出元の前日フォーマットを優先して揃える
