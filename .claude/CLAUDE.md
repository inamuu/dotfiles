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

