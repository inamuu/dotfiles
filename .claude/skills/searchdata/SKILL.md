---
name: searchdata
description: savedataで保存したセッション記録とGoogle Drive Docs配下のドキュメントから直近1年以内のものを検索し、番号付き一覧を表示してユーザーが選んだ記録を読み込む。過去の作業記録を探す・振り返るときに使用する。
---

# searchdata - セッション記録の検索・読み込み

以下2つのソースから直近1年以内の記録を検索し、キーワードで絞り込んだ一覧を表示して、ユーザーが選んだ番号のファイルを読み込む。

- Acta: `${HOME}/ghq/github.com/inamuu/data/Acta/posts/yyyy/mm/`（`/savedata` の記録）と `.../yyyy/mm/dd/`（デイリーノート）
- Docs: `${HOME}/Google Drive/マイドライブ/Docs/`（`/save-research` の調査メモなど）

引数でキーワードが渡された場合（例: `/searchdata 新opの開発環境の起動コマンド`）は、そのキーワードで内容検索して絞り込む。

## 手順

### 1. 対象ファイルの収集

直近1年分なので、ディレクトリ決め打ちではなく再帰的に集めてファイル名の日付でフィルタする。

**注意: このMacの `date` はGNU date（`-v` は使えない）。`date -d '-1 year'` を使うこと。**

```bash
CUTOFF=$(date -d '-1 year' +%Y-%m-%d)
LIST=/tmp/searchdata_list.txt   # scratchpadが指定されていればそちらへ

# Acta（ファイル名先頭の yyyy-mm-dd でフィルタ）
find "$HOME/ghq/github.com/inamuu/data/Acta/posts" -name '*.md' 2>/dev/null \
  | sort -r \
  | while read -r f; do
      d=$(basename "$f" | cut -c1-10)
      [[ "$d" > "$CUTOFF" ]] && echo "$f"
    done > "$LIST"

# Docs（ファイル名は yyyymmdd_ 形式。日付が取れないものも対象に含める）
find "$HOME/Google Drive/マイドライブ/Docs" -type f -name '*.md' 2>/dev/null | sort -r >> "$LIST"
```

- 1件も無ければ「直近1年の記録はありません」と伝えて終了する

### 2. キーワードで絞り込み

キーワードが与えられている場合、`rg -l` で内容検索する（`grep` ではなく `rg`）。

```bash
rg -l -i -e 'キーワード1' -e 'キーワード2' $(cat "$LIST") 2>/dev/null | sort -r
```

- キーワードは表記ゆれを考慮して複数パターンで検索する
  - 例:「新opの開発環境の起動コマンド」→ `新op` / `job-medley-operators` / `jm-op` / `dip rs` / `mdev start`
- ヒットが10件を超えたら、より具体的なコマンド名・固有名詞で再度絞り込む
- キーワードが無い場合は絞り込まず、新しい順に最大20件を一覧にする

### 3. 一覧の表示

新しい順に番号を付けて表示する。タイトルは以下で取得する。

- Acta のデイリーノート（`yyyy-mm-dd.md`）: 1行目は日付だけなので、`rg '^#{2,3} ' <file>` で見出しを拾い、該当しそうな見出しを表示する
- それ以外: `head -1` の `# ` 見出しを使う

```
「<キーワード>」に関連する記録（直近1年、Acta + Google Drive Docs 対象）:

1. 2026-07-21  job-medley app 開発環境 起動手順 / job-medley-operators 開発環境
2. 2026-07-16  NMW ローカル開発環境の起動手順
3. 2025-11-20  JobMedley 開発環境起動手順

読み込む番号を入力してください。
```

- タイトル取得は全ファイルまとめて行う（1件ずつReadしない）
- Docs 側にヒットが無かった場合はその旨を1行補足する
- 表示したらユーザーの入力を待つ（勝手に読み込まない）

### 4. 選択された記録の読み込み

- ユーザーが番号を入力したら、該当ファイルを読み込む
- デイリーノートの場合は、キーワードに該当するセクションを中心に提示する
- 内容を簡潔に提示し、以降の会話でその内容をコンテキストとして使えるようにする
- 複数番号（例: `1 3`）が入力されたら全て読み込む
- 番号以外（キーワード等）が入力されたら、一覧のタイトル・ファイル名から該当しそうなものを提示する

## 注意

- 出力は日本語、絵文字なし
- 一覧は簡潔に（番号・日付・タイトルのみ）
- 検索は `grep` ではなく `rg` を使う
- `date -v-1m` のようなBSD date構文は使わない（このMacはGNU date）
