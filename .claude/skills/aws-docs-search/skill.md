# AWS Documentation Search Skill

AWS公式ドキュメントを検索し、内容を取得するためのスキルです。

## 使用可能なツール

### 1. search_documentation
AWS公式ドキュメント全体を検索します。

**使い方:**
- 具体的な技術用語を使用する
- サービス名を含めると結果が絞り込まれる（例: "S3 bucket versioning"）
- 完全一致検索には引用符を使用（例: "AWS Lambda function URLs"）

**フィルター使用例:**
- "What is S3?" → product_types: ["Amazon Simple Storage Service"]
- "How to use Lambda with API Gateway?" → product_types: ["AWS Lambda", "Amazon API Gateway"]
- "S3 getting started" → product_types: ["Amazon Simple Storage Service"] + guide_types: ["User Guide"]
- "API reference for Lambda" → product_types: ["AWS Lambda"] + guide_types: ["API Reference"]

**パラメータ:**
- `search_phrase`: 検索フレーズ（必須）
- `search_intent`: 検索意図の説明（PII不可）
- `limit`: 最大結果数（1-50、デフォルト10）
- `product_types`: AWSサービスでフィルター（例: ["Amazon Simple Storage Service"]）
- `guide_types`: ガイド種類でフィルター（例: ["User Guide", "API Reference"]）

**レスポンス:**
- `search_results`: 検索結果（rank_order, url, title, context）
- `facets`: フィルター候補（product_types, guide_types）
- `query_id`: 検索セッションID

### 2. read_documentation
AWS公式ドキュメントページの内容をMarkdown形式で取得します。

**URLの要件:**
- docs.aws.amazon.com ドメインであること
- .html で終わること

**パラメータ:**
- `url`: ドキュメントページのURL（必須）
- `max_length`: 最大文字数（デフォルト5000、最大1000000）
- `start_index`: 開始位置（長文ドキュメントの続きを読む場合）

**長文ドキュメントの処理:**
- 1回目: `start_index=0`
- 2回目以降: 前回のレスポンス終了位置を `start_index` に指定
- 必要な情報が見つかれば途中で停止可能

### 3. recommend
ドキュメントページに関連するコンテンツを推薦します。

**推薦タイプ:**
- **Highly Rated**: 同じサービス内の人気ページ
- **New**: 同じサービス内の新規追加ページ（新機能発見に有効）
- **Similar**: 類似トピックのページ
- **Journey**: 他のユーザーが次に閲覧したページ

**新機能の見つけ方:**
1. サービスのウェルカムページURLを取得
2. このツールでそのURLを指定
3. **New** セクションを確認

**パラメータ:**
- `url`: 推薦元のドキュメントページURL（必須）

**レスポンス:**
各推薦は url, title, context を含む

## ベストプラクティス

1. **検索時**: 具体的な技術用語を使用
2. **長文読み込み**: 複数回に分けて `start_index` を使用
3. **関連コンテンツ**: 検索で見つからない場合は `recommend` を使用
4. **新機能確認**: `recommend` の **New** セクションを活用
5. **情報源の明示**: 必ずドキュメントURLを引用

## 使用例

```
# 例1: S3バケットの命名規則を検索
search_phrase: "S3 bucket naming rules"
search_intent: "Learn about S3 bucket naming conventions"

# 例2: Lambda関数URLsのドキュメントを読む
url: "https://docs.aws.amazon.com/lambda/latest/dg/lambda-urls.html"

# 例3: S3サービスの新機能を探す
url: "https://docs.aws.amazon.com/s3/index.html"
→ New セクションを確認

# 例4: 複数検索で結果不十分な場合
検索 → 検索 → recommend でピボット
```

## 注意事項

- 検索結果は最大50件まで
- 長文ドキュメント（>30,000文字）は必要な情報が見つかり次第停止
- 類似検索で結果不十分な場合は `recommend` に切り替える
- 必ずドキュメントURLを情報源として明記する
