# GitHub PR Create (Draft)

`gh pr create -d` を使用して Draft 状態の Pull Request を作成するスキルです。

## 手順

### 0. worktree とブランチの作成（必須）

- PR 用の作業は**必ず** worktree を作成して行う。worktree を作らずに PR を作成してはいけない。
- メインのブランチ（`master` / `main`）では作業しない。
- 既に worktree 上で作業している場合はそのまま利用してよい。判定は `git rev-parse --git-common-dir` と `--git-dir` が異なるかで行う。
- 共通ルールは `github` スキルに従う。
- ブランチ名は `feature/<issue番号>-<PRの内容を表す英語名>` とする（例: `feature/12345-add-ftp-params`）
- worktree は `~/worktrees/` 配下に作成する。ディレクトリ名は `<リポジトリ名>-<ブランチ名>`（ブランチ名の `/` は `-` に置換）

```bash
git worktree add ~/worktrees/<リポジトリ名>-feature-<issue番号>-<名前> -b feature/<issue番号>-<名前> origin/<デフォルトブランチ>
```

### 1. 変更差分の確認

以下のコマンドで現在のブランチの変更内容を把握する:

```bash
git diff $(git merge-base HEAD main)..HEAD
git log --oneline $(git merge-base HEAD main)..HEAD
```

※ デフォルトブランチが `main` でない場合は適切に読み替える。

### 2. Terraform 変更がある場合

変更された `.tf` ファイルを特定し、以下を実施する:

1. 変更対象のリソースを `-target` 指定して `terraform plan` を実行する
2. plan 結果を PR 本文に記載する
3. この変更により最終的にどのような状態になるかを説明する

### 3. その他の変更の場合

1. 変更差分を確認し、この変更でどのような状態になるかを説明する
2. 構成が変わる場合（アーキテクチャ変更、サービス間連携の変更、新規コンポーネント追加など）は mermaid 図を追加する

### 4. PR 作成

`gh pr create -d` でドラフト PR を作成する。タイトルは70文字以内。

作成時は**必ず** `--assignee @me` を付けて自分をアサインする。

本文は以下のフォーマットで HEREDOC を使用する。

**本文の骨格: 概要は3〜4行の箇条書き。それ以外の説明はすべて `<details>` で畳む。**

- 展開したまま見せるのは **概要 / Plan の結論1行 / 影響範囲 / 特に見て欲しいポイント / 周知有無** だけ
- 背景・判断理由・変更ファイル一覧・動作確認の詳細・今後の展開・plan 全文は `<details><summary>...</summary>` に入れる
- `<details>` の中身は詳しく書いてよい。畳んであれば長さは問題にならない
- レビュアーが判断すべき点は「特に見て欲しいポイント」に短く残し、根拠は `<details>` に置く

~~~bash
gh pr create -d --assignee @me --title "タイトル" --body "$(cat <<'PRBODY'
# 概要

- **Issue**: <issue の URL>
- 何のための変更か（1行）
- 何を変更したか（1行）
- 結果どうなるか（1行。plan が No changes ならそう書く）

# Plan

`terraform plan -target=...` → **Plan: X to add, Y to change, Z to destroy.**

<details><summary>Details</summary>
<p>

```terraform
(plan の差分。変更されるリソースの行が分かれば十分)
```

validate / fmt / pre-commit の結果もここに書く

</p>
</details>

# 影響範囲

- 1〜2行。どの環境・どのリソースに効くか

# 特に見て欲しいポイント

- レビュアーに判断してほしいことを1〜2項目

<details><summary>なぜこの変更か</summary>
<p>

背景・設計判断の根拠をここに書く

</p>
</details>

<details><summary>変更内容の詳細</summary>
<p>

| ファイル | 内容 |
|---|---|
| ... | ... |

</p>
</details>

# 動作確認ケース

<結論を1行>

<details><summary>Details</summary>
<p>

- 確認項目を箇条書き

</p>
</details>

# 周知有無

- 特になし

<details><summary>今後の展開</summary>
<p>

段階展開の順序や別issue案件をここに書く

</p>
</details>
PRBODY
)"
~~~

リポジトリに `.github/PULL_REQUEST_TEMPLATE.md` がある場合はそのセクション構成に合わせ、各セクションの中身を上記の方針（結論は展開、詳細は `<details>`）で書く。

### 5. 完了

作成した PR の URL を表示する。
openコマンドを使ってブラウザで表示する。

## 注意

- PR 本文・タイトル・セクション見出しはすべて日本語で記載する（`概要` / `詳細` / `Terraform Plan` / `アーキテクチャ`）
- 参照 issue は `## 概要` の直下に `issues: <issue の URL>` の形式で記載する。複数ある場合は URL をカンマ区切りで並べる。issue が存在しない場合はユーザーに確認する
- 作業は必ず worktree 上で行う（手順 0 参照）
- PR には必ず `--assignee @me` で自分をアサインする。オプションが使えなかった場合は `gh pr edit <PR番号> --add-assignee @me` でアサインし直す
- Terraform plan はユーザーに実行確認してから行う
- mermaid 図は構成変更がある場合のみ追加する（不要な場合は省略）
- 概要セクションは必須、Plan / アーキテクチャセクションは該当する場合のみ記載
- 展開したまま見える本文が長くなったら `<details>` に畳む。畳める情報は畳む

### 書き方の方針（重要）

**長い PR はレビューされない。** 展開されたまま見える部分は極限まで短くし、詳細は `<details>` に畳む。

**基準: 開いた一画面で「何をやっていて」「何をやりたいか」「何が論点か」が分かること。** それ以外はすべてトグルの中。

- **概要は3〜4行**。Issue リンク + 何のため + 何を変更 + 結果どうなるか
- 展開したまま見せるのは 概要 / Plan の結論 / 影響範囲 / 特に見て欲しいポイント / 周知有無 だけ
- 背景・判断根拠・変更ファイル一覧・動作確認の詳細・plan 全文・今後の展開は **すべて `<details>` に入れる**
- 情報を削るのではなく畳む。`<details>` の中身は詳しく書いてよい
- レビュアーが判断すべき点は「特に見て欲しいポイント」に短く置き、根拠は `<details>` に逃がす
- 追加・変更したリソースを 1 つずつ網羅列挙しない。差分はコードと plan を見れば分かる
- 設計判断の根拠はコード内コメントにも残す

