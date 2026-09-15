---
name: searchdata
description: savedata で保存したセッション記録（Acta デイリーノート）と Google Drive Docs 配下のドキュメントから直近1年以内のものを検索し、番号付き一覧を表示してユーザーが選んだ記録を読み込む。ToDo 系タグのブロックは除外する。「過去の記録を探して」「前に調べた〜を読んで」「readdata」と頼まれたとき、および /searchdata と入力されたときに使用する。
---

# searchdata - セッション記録の検索・読み込み

`search.py` で以下 2 ソースの記録を検索し、一覧からユーザーが選んだ番号の本文を表示する。

- Acta: `${HOME}/ghq/github.com/inamuu/data/Acta/posts/`（`/savedata` の記録、デイリーノート）
- Docs: `${HOME}/Google Drive/マイドライブ/Docs/`（`/save-research` の調査メモなど）

検索単位は `acta:comment` ブロック（ブロックが無いファイルはファイル全体）。
`tags:` に ToDo 系（`ToDo` / `ToDo_Medley` など `todo` を含むもの）を持つブロックと、本文先頭が `# ToDo:` のブロックは既定で除外する。

## スクリプト

```bash
python3 ~/.claude/skills/searchdata/search.py -k KEYWORD [-k KEYWORD ...] [--limit N]
python3 ~/.claude/skills/searchdata/search.py --show N [N ...]
```

| オプション | 内容 |
|---|---|
| `-k KEYWORD` | 検索キーワード（正規表現、大文字小文字無視）。複数指定は OR。省略時は全件を新しい順に表示 |
| `--limit N` | 表示件数（既定 20） |
| `--days N` | 対象期間（既定 365 日） |
| `--include-todo` | ToDo 系タグのブロックも含める（ユーザーが明示した場合のみ） |
| `--show N ...` | 直前の検索結果の番号で本文を表示（結果は `~/.cache/searchdata/index.json` に保存される） |

出力は `番号. 日付 [Acta|Docs] タイトル (tags)` の一覧。Docs 側にヒットが無い場合はその旨が 1 行出る。

## 手順

### 1. 検索

- 引数でキーワードが渡された場合（例: `/searchdata 新opの開発環境の起動コマンド`）は、表記ゆれを考慮して `-k` を複数並べて検索する
  - 例:「新opの開発環境の起動コマンド」→ `-k 新op -k job-medley-operators -k jm-op -k 'dip rs' -k 'mdev start'`
- キーワードが無い場合は `-k` なしで実行し、新しい順に最大 20 件を表示する
- ヒットが 10 件を超えたら、より具体的なコマンド名・固有名詞で再検索して絞り込む
- 「該当する記録はありません」の場合はそのまま伝えて終了する

### 2. 一覧の表示

スクリプトの出力をそのまま提示し、ユーザーの入力を待つ（勝手に読み込まない）。

```
「<キーワード>」に関連する記録（直近1年、Acta + Google Drive Docs 対象）:

1. 2026-09-15  [Acta]  NMW 本番の旧 Redis 削除 PR 作成と mask_data S3 同期ジョブの sandbox 移行調査
2. 2026-09-03  [Docs]  SB CDN 403 の原因調査と S3 オブジェクト所有者の是正手順

読み込む番号を入力してください。
```

### 3. 選択された記録の読み込み

- ユーザーが番号を入力したら `--show N` で本文を取得する。複数番号（例: `1 3`）は `--show 1 3`
- 内容を簡潔に提示し、以降の会話でその内容をコンテキストとして使えるようにする。本文が長い場合はキーワードに該当する箇所を中心に要約し、全文が必要なら `file:` のパスを示す
- 番号以外（キーワード等）が入力されたら、一覧のタイトルから該当しそうなものを提示するか、そのキーワードで再検索する

## 注意

- 出力は日本語、絵文字なし
- 一覧は簡潔に（番号・日付・タイトルのみ）
- 検索は必ず `search.py` を使う。`find` / `grep` で自前実装しない
- ToDo 系ブロックはユーザーが「ToDo も含めて」と明示した場合のみ `--include-todo` を付ける
