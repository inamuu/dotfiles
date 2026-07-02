# GitHub PR Create (Draft)

`gh pr create -d` を使用して Draft 状態の Pull Request を作成するスキルです。

## 手順

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

本文は以下のフォーマットで HEREDOC を使用する:

~~~bash
gh pr create -d --title "タイトル" --body "$(cat <<'EOF'
## 概要
- 何のための変更か / 何を追加・変更するかを端的に箇条書き
- 関連 issue があれば先頭に `issue: <URL>` を載せる

## 詳細
- 「何のための PR か」と「結果どうなるか」を数行で説明する
- 秘匿値の Deny など重要なポイントは、項目だけを短い箇条書きで列挙する

<!-- Terraform 変更がある場合 -->
## Terraform Plan
`terraform plan -target=...` → **Plan: X to add, Y to change, Z to destroy.**

<details>
<summary>plan 結果</summary>

```tf
(terraform plan の差分。変更されるリソースの行が分かれば十分)
```

</details>

<!-- 構成変更がある場合のみ -->
## アーキテクチャ
```mermaid
(構成図)
```
EOF
)"
~~~

### 5. 完了

作成した PR の URL を表示する。
openコマンドを使ってブラウザで表示する。

## 注意

- PR 本文・タイトル・セクション見出しはすべて日本語で記載する（`概要` / `詳細` / `Terraform Plan` / `アーキテクチャ`）
- Terraform plan はユーザーに実行確認してから行う
- mermaid 図は構成変更がある場合のみ追加する（不要な場合は省略）
- Summary セクションは必須、Detail / Terraform Plan / Architecture セクションは該当する場合のみ記載

### 書き方の方針（重要）

人間が最後まで読めるよう、短く・読んで理解できる粒度で書く。長い PR は途中で読まれない。

- 追加・変更したリソースを 1 つずつ「何をアタッチした」と網羅列挙しない。差分はコードと plan を見れば分かる
- 設計判断の根拠を本文に長々と箇条書きしない。詳細はコード内コメントに残し、本文には結論だけ書く
- Detail は「何のための PR か」＋「重要なポイント（項目の短い箇条書き）」程度にとどめる
- 迷ったら削る。情報の網羅性より、読み手がすぐ要点を掴めることを優先する

