# Kubernetes Incident Helper

Kubernetes の問題を解析し、根本原因と対処法を提示するスキルです。

## 入力

以下の1つ以上:
- `kubectl describe pod <name>` の出力
- `kubectl logs <name>` の出力
- `kubectl get events` の出力
- エラーメッセージのテキスト

引数がない場合は「kubectl describe / logs / events の出力を貼り付けてください」と聞く。

## 検出パターン

### Pod ステータス異常

| 状態 | 原因候補 | 対処 |
|---|---|---|
| ImagePullBackOff | イメージ名誤り・タグ未存在・ECR 認証失敗・プライベートレジストリ設定なし | イメージ名/タグ確認、imagePullSecret 設定 |
| CrashLoopBackOff | アプリが非ゼロで終了・起動コマンド誤り・設定ファイル欠損 | コンテナログ確認、CMD/ENTRYPOINT 確認 |
| OOMKilled | メモリ上限超過 | resources.limits.memory 引き上げ、またはアプリのメモリリーク調査 |
| Pending | ノードリソース不足・Node selector/Affinity 不一致・PVC バインド失敗 | `kubectl describe pod` の Events 確認、ノード容量確認 |
| CreateContainerConfigError | ConfigMap/Secret が存在しない | 参照先リソースの存在確認 |

### イベント異常

- `FailedScheduling`: ノードリソース不足または Taint/Toleration ミスマッチ
- `BackOff`: 再起動ループ、ログで終了コード確認
- `Unhealthy`: Liveness/Readiness probe 失敗
- `FailedMount`: PV/PVC または ConfigMap/Secret マウント失敗

### ネットワーク・DNS

- `dial tcp: lookup`: DNS 解決失敗 (CoreDNS 確認)
- `connection refused`: サービスが起動していないか Port ミスマッチ
- `upstream connect error`: バックエンドが応答していない

### ECR 認証

- `401 Unauthorized` または `no basic auth credentials`: ECR トークン期限切れ
  - 対処: `aws ecr get-login-password` + `imagePullSecret` 更新、または IRSA/EKS IAM 設定確認

## 出力フォーマット

```
## Kubernetes Incident Analysis

### 検出された問題
(検出内容)

### 考えられる原因
1. (原因1)
2. (原因2)

### 推奨対処
1. (コマンドや手順を含む具体的な対処)
2. ...

### 確認コマンド
\`\`\`bash
# (調査に役立つコマンド)
\`\`\`
```

## 注意

- 複数の問題が検出された場合は優先度の高い順に並べる
- 出力は日本語
