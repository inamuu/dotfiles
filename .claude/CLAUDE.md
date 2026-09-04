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

## Shell commands in output

- Claude Code の表示は長い行を折り返し、画面からコピーすると折り返し位置に改行が混ざる。そのため画面に表示するコマンドは 80 文字以内の短いものに限る
- 80 文字を超えるコマンド、for/while、複数行の処理は /tmp/ 配下のスクリプトファイルに書き出し、`bash /tmp/xxx.sh` のような短い実行コマンドだけを提示する
- ファイル化したときは中身の説明（何をするか、出力の見方）を文章で添える
- `\` による行継続は使わない

## AWS CLI

- aws コマンドを提示・生成するときは常に `--no-cli-pager` を付ける
