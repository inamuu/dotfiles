# Language

- Japanese

## Outputs

- Markdown
- 日本語で出力すること
- シンプルに回答すること（長いと遡らないといけないので）
- 絵文字は使用しないこと

## Search files

- grepではなく、高速なのでrg(ribgrep)を使用して

## Repositories

- ローカルリポジトリはすべて ghq 管理（root: `~/ghq`）
- リポジトリを探すときは find や mdfind ではなく `ghq list -p <名前>` を使うこと

## Permissions

- allow / deny ルールを追加・変更する場合は `~/.config/claude/settings.local.json` の `permissions.allow` / `permissions.deny` を編集すること
- `settings.json` は Claude Code が自動書き換えするため gitignore している

## Documents

- 「ドキュメントを保存して」「記録しておいて」など、作業内容の保存・記録・ドキュメント化を頼まれたら savedata スキルを実行すること
- 保存先を Google Drive と明示された場合のみ save-research を使う
- ~/.claude/docs/ など独自の場所に勝手にファイルを作らないこと
