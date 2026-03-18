# GitHub PR Create (Draft)

`gh pr create -d` を使用して Draft Pull Request を作成するスキルです。

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

```bash
gh pr create -d --title "タイトル" --body "$(cat <<'EOF'
## Summary
- (変更概要を箇条書き)

## Detail
(変更によりどのような状態になるかの説明)

<!-- Terraform 変更がある場合 -->
## Terraform Plan
<details>
<summary>plan 結果</summary>

```
(terraform plan の出力)
```

</details>

<!-- 構成変更がある場合 -->
## Architecture
```mermaid
(構成図)
```

EOF
)"
```

### 5. 完了

作成した PR の URL を表示する。

## 注意

- PR 本文は日本語で記載する
- Terraform plan はユーザーに実行確認してから行う
- mermaid 図は構成変更がある場合のみ追加する（不要な場合は省略）
- Summary セクションは必須、Detail / Terraform Plan / Architecture セクションは該当する場合のみ記載
