---
name: cwlog-analyze
description: CloudWatch ログやアプリケーションログを解析し、運用上の問題を検出する。ログ調査を頼まれたときに使う。
---

# CloudWatch Log Analyzer

CloudWatch ログ・アプリケーションログを解析し、運用上の問題を検出するスキルです。

## 入力

以下のいずれか:
- CloudWatch Logs の出力テキスト
- アプリケーションログ (JSON / テキスト問わず)
- `aws logs get-log-events` の出力

引数がない場合は「解析したいログを貼り付けてください」と聞く。

## 検出パターン

### データベース
- `connection refused` / `connection timed out` → DB 接続失敗
- `too many connections` → コネクション枯渇
- `deadlock` → デッドロック
- `slow query` / `Query_time` が閾値超 → スロークエリ

### キャッシュ / Redis
- `READONLY You can't write against a read only replica` → Redis フェイルオーバー中
- `Connection timed out` → Redis タイムアウト
- `OOM command not allowed` → Redis メモリ枯渇

### HTTP / API
- `5xx` エラー多発 (500, 502, 503, 504)
- `upstream timed out` / `Gateway Timeout` → バックエンド応答遅延
- `connect() failed` → バックエンド接続失敗

### メモリ / OOM
- `Out of memory` / `Killed process` → OOM Killer 発動
- Java `OutOfMemoryError` / `GC overhead limit exceeded`
- `Cannot allocate memory`

### アプリケーション
- スタックトレース / `panic:` / `FATAL`
- 認証エラー: `401` / `403` / `Unauthorized` / `Forbidden` の多発
- レート制限: `429 Too Many Requests`

## 出力フォーマット

```
## Log Analysis

### 検出されたパターン
- (パターン名): (件数または初出時刻) - (該当ログ抜粋)

### 考えられる原因
1. (原因)

### 推奨アクション
1. (具体的なアクション)

### タイムライン (ある場合)
- HH:MM - (イベント)
- HH:MM - (イベント)
```

## 注意

- エラー件数・頻度・時刻パターンを整理して報告する
- 問題が重複している場合はグループ化する
- 出力は日本語
