# AWS Cost Analyzer

インフラ定義から AWS 月額コストを概算するスキルです。

## 入力

以下のいずれか:
- Terraform plan 出力
- `aws` CLI 出力
- リソース一覧 (テキスト記述でも可)

引数がない場合は「コスト試算したいリソース情報を貼り付けてください」と聞く。

## 解析対象とコスト概算

以下の典型的な AWS リージョン価格 (ap-northeast-1 / us-east-1) を基に試算する:

### EC2
- t3.micro: $8/月
- t3.small: $15/月
- t3.medium: $30/月
- t3.large: $60/月
- t3.xlarge: $120/月
- m5.large: $70/月
- m5.xlarge: $140/月
- m5.2xlarge: $280/月
- r5.large: $100/月

### ALB
- 基本料金: $18/月 (LCU 別途)

### NAT Gateway
- $30/月/個 (データ転送費用別途)

### RDS (シングル AZ)
- db.t3.micro: $15/月
- db.t3.small: $30/月
- db.t3.medium: $60/月
- db.r5.large: $140/月
- Multi-AZ は約2倍

### ElastiCache / Redis
- cache.t3.micro: $12/月
- cache.t3.small: $24/月
- cache.r6g.large: $100/月

### EBS
- gp3: $0.08/GB/月
- io1: $0.125/GB/月 + $0.065/IOPS/月

## 出力フォーマット

```
## 推定月額コスト

### EC2
- (インスタンスタイプ) × (台数) ≈ $XX

### ALB
≈ $XX

### NAT Gateway
≈ $XX

### RDS
≈ $XX

### ElastiCache
≈ $XX

### EBS
≈ $XX

---
**合計: ≈ $XXX/月**

> 注意: 概算値です。データ転送料・SnapShot・ログ等は含まれていません。
```

## 注意

- 情報が不足している場合は仮定を明示して試算する
- 出力は日本語
- コスト削減の提案があれば末尾に「コスト最適化ヒント」として追記する
