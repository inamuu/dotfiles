---
name: dep-audit
description: 今のリポジトリで使っているライブラリ（npm / pnpm / その他 trivy 対応言語）の既知の脆弱性をチェックし、Critical / High / Moderate / Low のレベル別にリスクと修正内容を Markdown でまとめて画面に出力し、レベルごとに対処するかユーザーに確認してから修正する。「脆弱性チェックして」「ライブラリのセキュリティチェック」「npm audit して」「依存関係の脆弱性を確認」と頼まれたとき、および /dep-audit と入力されたときに使用する。
---

# dep-audit - 依存ライブラリ脆弱性チェック

## 1. スキャン

```bash
node ~/.claude/skills/dep-audit/scripts/audit.mjs .
```

- 結果は JSON で出力される。ユーザー向けの報告は手順 3 で Claude が Markdown にまとめる。
- `package-lock.json` があれば `npm audit`、`pnpm-lock.yaml` があれば `pnpm audit`、それ以外は `trivy fs` を使う。
- JSON の各項目: `severity` / `package` / `direct`（直接依存か）/ `runtime`（`--omit=dev` でも残る＝本番に入るか）/ `fix`（修正方法）/ `advisories`（タイトルと URL）。
- npm 系で lock ファイルが無い、trivy も無い場合はその旨を伝えて終了する。

## 2. レベル判定

`severity` をベースに、本番影響で補正する。

| レベル | 基準 | 既定の方針 |
|---|---|---|
| Critical | severity=critical | 対処する |
| High | severity=high | 対処する |
| Moderate | severity=moderate | 内容を見て判断 |
| Low | severity=low | 原則見送り |

補正ルール:
- `runtime=false`（dev 専用）は 1 段下げて扱ってよい。ただし Electron アプリの `electron`、ビルド成果物に同梱されるものは本番扱い。
- 修正が major 更新（`(major更新)`）のものは破壊的変更リスクありと明記する。
- 「修正版なし」は対処不能として別枠で報告する。

## 3. 報告（Markdown サマリ）

スキャン結果を Claude の応答として **Markdown で画面に直接出力** する（ファイルには保存しない）。
各パッケージについて「何が起きうるか」「何をどう直すか」が読んで分かるようにする。

書き方:
- advisory のタイトルは英語のまま貼らず、**日本語で攻撃内容と影響**を 1 文で書く（例: 「細工した Markdown を表示すると任意のスクリプトが実行される（XSS）」）。
- 可能なら**このリポジトリでの使われ方**に照らした影響を一言添える（例: 「Acta ではノート本文の描画に使っているため影響あり」「ビルド時のみ使用で配布物には入らない」）。使われ方は `rg <pkg>` で確認する。
- 修正内容は「現行バージョン → 修正後バージョン」と方法を書く。現行バージョンは `npm ls <pkg>` で確認する。間接依存はどの親パッケージ経由か（`via`）も書く。
- major 更新が必要なものは破壊的変更リスクを明記する。
- advisory の URL はパッケージ名にリンクする。
- 同じ親の更新で一括で直るものはまとめてよい。

テンプレート:

```markdown
## 脆弱性チェック結果（npm audit）

Critical 2 / High 8 / Moderate 1 / Low 2（うち本番に入るもの 4 件）

### Critical（2件）

| パッケージ | 種別 | リスク | 修正内容 |
|---|---|---|---|
| [dompurify](URL) | 直接・本番 | 特定の HTML でサニタイズをすり抜け XSS が成立する。Acta ではプレビュー描画に使用しており影響あり | 3.0.9 → 3.2.x（`npm install dompurify@3.2.x`、minor 更新） |
| [shell-quote](URL) | 間接・dev（concurrently 経由） | 引数のエスケープ不備でコマンド注入。dev スクリプトのみで配布物には入らない | 1.8.1 → 1.8.3（`npm audit fix`） |

### High（8件）
...

### 対処不能（修正版なし）
- xxx: 理由

### まとめ
- すぐ対処すべきもの: dompurify, markdown-it（本番・直接依存）
- `npm audit fix` で一括修正できるもの: N 件
- 個別判断が必要なもの: mermaid（major 更新）
```

## 4. 対処の確認

AskUserQuestion で **レベルごと** に確認する（該当件数 0 のレベルは聞かない）。1 回の呼び出しで最大 4 問まとめてよい。

- 質問例: 「Critical（2件）を対処しますか？」
- 選択肢:
  - `対処する`（Critical/High では先頭に置き (Recommended) を付ける）
  - `本番影響のみ対処`（runtime=true のものだけ）
  - `見送る`（Low では先頭に置き (Recommended) を付ける）

## 5. 対処

承認されたレベルのパッケージだけ修正する。

1. 作業前に `git status` で lock ファイルが未変更であることを確認する。main/master 上なら作業ブランチを切るか確認する。
2. 修正方法の優先順:
   - 直接依存: `npm install <pkg>@<修正版>`（major 更新は再度確認してから）
   - 推移的依存: まず `npm audit fix`（`--force` は使わない）。対象外のレベルまで直る場合は、`npm update <pkg>` か親パッケージの更新で個別に対応する。それでも無理なら `package.json` の `overrides` を提案する。
3. 修正後に再スキャンして件数の変化を報告する。
4. `package.json` の `scripts` に `test` / `build` があれば実行し、壊れていないか確認する。
5. コミットはユーザーに頼まれた場合のみ（commit-push スキルを使う）。

## 注意

- `npm audit fix --force` は無断で実行しない（major 更新を勝手に入れるため）。
- ファイル削除が必要な場合は `rm` ではなく `mv <対象> ~/.Trash/`。
