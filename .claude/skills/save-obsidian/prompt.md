# Obsidian Vault Save Skill

会話中の調査結果やレポートをObsidian Vaultに保存する。

## 保存先の判定

ユーザーの指示に応じて保存先を切り替える。

| 指示 | Vault | 保存先パス |
|---|---|---|
| 「worksへ保存して」 | Works（仕事関連） | `/Users/kazuma.inamura/ghq/github.com/inamuu/obsidian/Vaults/Works/raw/` |
| 「privateへ保存して」 | Private（プライベート関連） | `/Users/kazuma.inamura/ghq/github.com/inamuu/obsidian/Vaults/Private/raw/` |

**必ず各Vaultの `raw/` ディレクトリに保存すること。他のディレクトリには保存してはならない。**

## 実行手順

1. **保存先Vaultを判定**
   - ユーザーの指示から works / private を判定する
   - 明示されていない場合はユーザーに確認する

2. **保存先ディレクトリの確認**
   - `raw/` ディレクトリが存在しない場合は作成する

3. **ファイル名を決定**
   - 内容を端的に表す英語のケバブケース（例: `jm-qa-s3-acl-issue.md`）
   - 日付が重要な場合はプレフィックスに付与（例: `2026-04-06-deploy-failure.md`）

4. **Markdown形式で保存**
   - 見出し、リスト、テーブル、コードブロックを適切に使用
   - 最上位見出し（`#`）にタイトルを記載

5. **保存完了を報告**
   - 保存先のフルパスを表示

## 重要な注意点

- 既存ファイルがある場合は上書き前にユーザーに確認する
- 機密情報（クレデンシャル、APIキーなど）は保存しない
- Obsidianで読みやすいMarkdown形式を心がける
- `raw/` 以外のディレクトリには絶対に保存しない
