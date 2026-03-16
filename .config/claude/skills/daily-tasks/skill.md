# Daily Tasks (Acta)

このコマンドは、Acta の前日 `ToDo_Medley` タスクを本日分へ引き継いで整形するための専用コマンドです。

## 対象ディレクトリ
`$HOME/ghq/github.com/inamuu/data/Acta/`

**注意**: パスは `$HOME` 環境変数を使用するため、どのMacでも動作します。

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
  - **実装ヒント**: `TZ=Asia/Tokyo date '+%Y-%m-%d'` で今日、`TZ=Asia/Tokyo date -j -v-1d '+%Y-%m-%d'` で前日（macOS）
  - **Linux/macOS両対応**: `TZ=Asia/Tokyo date -d '1 day ago' '+%Y-%m-%d' 2>/dev/null || TZ=Asia/Tokyo date -j -v-1d '+%Y-%m-%d'`
2. 過去の `ToDo_Medley` ブロックを効率的に取得する
  - まず `yesterday_ymd.md` が存在するか確認し、存在すれば読み込む
  - ファイル内に `tags: ToDo_Medley` かつ `# Tasks:` を含む `<!-- acta:comment -->` ブロックがあるか確認
  - **ない場合**：以下の効率的な方法で最新ファイルを特定
    - Bashコマンドで最新ファイルを取得: `ls -1 $HOME/ghq/github.com/inamuu/data/Acta/20*.md 2>/dev/null | sort -r | head -1`
    - または、`Grep` ツールで `tags:.*ToDo_Medley` を検索し、結果のファイル名をソート（降順）して先頭を取得
  - 最新の `ToDo_Medley` ブロックを抽出する（同じファイル内に複数ある場合は最後のもの）
3. 抽出した `# Tasks: XXXXXXXX` を `# Tasks: {today_compact}` に置き換える
4. 完了済みタスクを削除する
  - 削除対象: 行中に `- [x]` を含むタスク行のみ
  - 継続対象: `- [ ]`, `- [/]`, `- [R]`, `- [R ]` のタスク行
  - `- [X]` は削除しない
  - 子タスク削除後に配下が空になった見出し行（例: `- その他`）は削除する
5. 今日のファイルを更新する
  - ファイル: `$HOME/ghq/github.com/inamuu/data/Acta/{today_ymd}.md`
  - ファイルがない場合は、先頭に `# {today_ymd}` を作成してから追記する
  - `tags: ToDo_Medley` の `acta:comment` ブロックとして保存する
  - メタデータ
    - `id`: UUID v4（**実装ヒント**: `uuidgen | tr '[:upper:]' '[:lower:]'`）
    - `created`: `YYYY-MM-DD HH:MM`（**実装ヒント**: `TZ=Asia/Tokyo date '+%Y-%m-%d %H:%M'`）
    - `created_ms`: Unix timestamp (milliseconds)（**実装ヒント**: `TZ=Asia/Tokyo date '+%s000'`）
    - `tags`: `ToDo_Medley`
  - **重要**: Python の pytz などの外部ライブラリに依存せず、シェルコマンド（date、uuidgen）で完結させる
6. 保存後、必ず次の質問をユーザーに返す
  - `追加したいタスクはありますか？`
7. ユーザーが `XXを追加して` と回答した場合
  - 直前に作成した本日分 `ToDo_Medley` ブロックの `# Tasks: {today_compact}` 配下に追加する
  - **追加先の判定**:
    - ユーザーが「YYセクションにXXを追加」と指示した場合 → 該当セクション（例: `- AWSアカウント分割QA`）配下に追加
    - セクション指定がない場合 → `- その他` セクション直下に追加
    - `- その他` が無い場合は `---` 区切りの前に新規作成してから追加
  - 追加形式: `- [ ] XX`（インデントは既存タスクと同じレベルで揃える）
8. 追加結果を短く報告して終了する

## 出力ルール
- 返答は日本語
- 変更したファイルパスと実施内容を短く示す
- Markdown のインデント・記法は、抽出元の前日フォーマットを優先して揃える

## 実装の効率化ポイント
1. **並列実行**: 日付取得コマンドは複数同時に Bash ツールで実行可能（today、yesterday、timestamp、uuid を並列取得）
   - Linux/macOS両対応のコマンドを使用: `TZ=Asia/Tokyo date -d '1 day ago' '+%Y-%m-%d' 2>/dev/null || TZ=Asia/Tokyo date -j -v-1d '+%Y-%m-%d'`
2. **前日ファイル確認の流れ**:
   - Step 1: 前日ファイルを直接 `Read` で読み込み（存在しなければエラーが返る）
   - Step 2a: 読み込み成功 → `tags: ToDo_Medley` があるか判定
   - Step 2b: 読み込み失敗または ToDo_Medley がない場合 → Bashコマンドで最新ファイルを特定: `ls -1 $HOME/ghq/github.com/inamuu/data/Acta/20*.md 2>/dev/null | sort -r | head -1`
   - 最新ファイルを `Read` で読み込み
3. **完了タスク削除**: 抽出したブロック内のテキストから `- [x]` を含む行を除去（Python や sed は不要、文字列処理で対応）
4. **ファイル作成**: `Write` ツールで一度にファイル作成（既存ファイルがある場合は先に `Read` で読み込み、追記する）
