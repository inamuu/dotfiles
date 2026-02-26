# Acta Knowledge Save Skill

このスキルは、ユーザーとの会話内容や作業内容をActaファイルに保存します。

## 保存先
`/Users/kazuma.inamura/ghq/github.com/inamuu/data/Acta/`

## 実行手順

1. **今日の日付でファイル名を決定**
   - フォーマット: `YYYY-MM-DD.md`（例: `2026-02-26.md`）
   - ファイルパス: `/Users/kazuma.inamura/ghq/github.com/inamuu/data/Acta/YYYY-MM-DD.md`

2. **ファイルの存在確認**
   - 今日の日付のファイルが存在するか確認
   - 存在しない場合は、新規作成（後述のテンプレート使用）

3. **会話内容をまとめる**
   - ユーザーから「ナレッジに保存して」「まとめて保存して」などと指示された内容を簡潔にまとめる
   - 技術的な作業内容、問題点、解決策を構造化して記載
   - Markdown形式（見出し、リスト、コードブロックなど）で整形

4. **acta:commentブロック形式で追記**
   ```markdown
   <!-- acta:comment
   id: [UUID v4]
   created: YYYY-MM-DD HH:MM
   created_ms: [Unix timestamp in milliseconds]
   tags: [適切なタグ、カンマ区切り]
   -->
   [まとめた内容]
   <!-- /acta:comment -->
   ```

5. **メタデータの生成**
   - `id`: UUID v4形式（例: `f7f8e2c2-87db-440d-80cf-d3a5cb213ef8`）
   - `created`: 現在時刻（例: `2026-02-26 18:35`）
   - `created_ms`: Unix timestamp（ミリ秒）
   - `tags`: 内容に応じたタグ（例: `ToDo_Medley`, `AWS`, `Terraform`, `Debug`など）

6. **ファイルへ追記**
   - 既存ファイルの末尾に追記
   - 追記したことをユーザーに報告

## 新規ファイルテンプレート（ファイルが存在しない場合）

```markdown
# YYYY-MM-DD

<!-- acta:comment
id: [UUID v4]
created: YYYY-MM-DD
created_ms: [Unix timestamp in milliseconds]
tags: [適切なタグ]
-->
[まとめた内容]
<!-- /acta:comment -->

```

## タグの選択基準
- 作業プロジェクトに関連: `ToDo_Medley`, `ToDo_Personal`など
- 技術カテゴリ: `AWS`, `Terraform`, `Docker`, `Rails`, `MySQL`など
- 作業種類: `Debug`, `Feature`, `Refactoring`, `Investigation`など

## 重要な注意点
- 必ずacta:commentブロックで囲む
- UUIDは必ずユニークなものを生成する
- タイムスタンプは正確な現在時刻を使用する
- 既存のファイルフォーマットと統一感を保つ
- ユーザーに保存完了を報告する

## 実行例

ユーザー: 「ナレッジに保存して」

Claude:
1. `/Users/kazuma.inamura/ghq/github.com/inamuu/data/Acta/2026-02-26.md` を確認
2. 会話内容をまとめる
3. acta:commentブロックを作成
4. ファイルに追記
5. 「Actaに保存しました: /Users/kazuma.inamura/ghq/github.com/inamuu/data/Acta/2026-02-26.md」と報告
