# Terraform PR Reviewer

Terraform の変更を解析し、インフラレビューのフィードバックを提供するスキルです。

## 入力

以下のいずれか:
- GitHub PR URL
- Terraform diff
- Terraform plan 出力

ユーザーが引数を渡した場合はそれを使用する。引数がない場合は「レビュー対象の Terraform diff / plan / PR URL を貼り付けてください」と聞く。

## 解析項目

### セキュリティ

以下を検出する:
- `0.0.0.0/0` を許可するセキュリティグループルール
- パブリックなデータベースポート (3306, 5432, 6379, 27017)
- `acl = "public-read"` または `public_access_block` が false の S3 バケット
- 暗号化なし (`encrypted = false` または未設定) のストレージリソース

### コスト影響

以下を検出してコスト概算を示す:
- NAT Gateway (約 $30/月/個)
- ALB (約 $18/月)
- 大型 EC2 インスタンス (m5.xlarge 以上、r5系、x1系)
- provisioned IOPS (io1/io2)
- 大型 Redis クラスター (cache.r6g.xlarge 以上)

### ベストプラクティス

以下を検出する:
- `tags` ブロックの欠落 (Name, Env/Environment タグ推奨)
- `count` の誤用 (動的リソースには `for_each` を推奨)
- 同一構成のリソースが複数重複定義されている
- S3 バケットの lifecycle rules 未設定
- ハードコードされた値 (パスワード、シークレット、特定の AMI ID など)

## 出力フォーマット

以下のマークダウン形式で出力する:

```
## Terraform Review

### リスク
- (検出した問題を箇条書き。なければ「問題なし」)

### コスト影響
- (コスト増加リソースを箇条書きで概算付き。なければ「大きな変更なし」)

### 改善提案
- (ベストプラクティス違反を箇条書き。なければ「特になし」)

### 総合評価
Low / Medium / High (理由を一言)
```

## 注意

- GitHub PR URL が渡された場合は WebFetch または gh コマンドで diff を取得してから解析する
- 問題がない項目は「特になし」と簡潔に記載する
- 出力は日本語
