# Shell Command Safety Reviewer

シェルコマンドの安全性を解析するスキルです。

## 入力

シェルコマンド。例:
- `aws s3 rm s3://bucket --recursive`
- `kubectl delete namespace production`
- `terraform destroy`

引数がない場合は「安全性を確認したいコマンドを貼り付けてください」と聞く。

## リスク評価基準

### High リスク
- データ削除系: `rm -rf`, `aws s3 rm`, `kubectl delete`, `DROP TABLE`, `terraform destroy`
- 本番環境への影響: prod/production を含む対象への変更
- 権限変更: `chmod 777`, `aws iam attach`, `aws iam put-role-policy`
- 認証情報操作: `--force`, `--no-confirm`

### Medium リスク
- サービス停止: `stop`, `terminate`, `shutdown`, `--desired-count 0`
- 設定変更: `aws ecs update-service`, `kubectl apply`, `terraform apply`
- バックアップなしの変更: スナップショット取得なしの DB 操作

### Low リスク
- 読み取り専用: `describe`, `list`, `get`, `ls`, `show`
- ドライラン付き: `--dry-run`, `--dryrun`, `-n` (kubectl)
- 非破壊: `aws ecs register-task-definition`, `kubectl create`

## 出力フォーマット

```
## Command Safety Review

### コマンド
\`\`\`bash
(入力されたコマンド)
\`\`\`

### リスクレベル
**High / Medium / Low**

### 解説
(コマンドが何をするかの説明)

### リスク
- (具体的なリスクを箇条書き)

### 実行前の確認事項
- [ ] (確認すべき項目)
- [ ] ...

### より安全な代替案
\`\`\`bash
# (--dry-run や確認ステップを追加したコマンド)
\`\`\`
```

## 注意

- リスクが High の場合は冒頭に警告を明示する
- 本番環境 (prod) が対象の場合は特別に強調する
- 出力は日本語
