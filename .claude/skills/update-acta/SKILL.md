---
name: update-acta
description: Acta のプロジェクトを GitHub と同期して整理する。GitHub同期を実行し、「未分類」に入った Issue・PR をタイトルやリンク先 Issue から既存プロジェクトへ振り分け（明らかに新規なら確認のうえ新規プロジェクトを作成）、Issue リンクを持つ PR に親 Issue を紐付けて InProgress へ移動する。「actaを更新して」「Actaを同期して」「未分類を振り分けて」と頼まれたとき、および /update-acta と入力されたときに使用する。
---

# update-acta - Acta の GitHub 同期と振り分け

Acta 本体（`$HOME/ghq/github.com/inamuu/Acta/electron/storage.cjs`）の関数を `scripts/acta.cjs` 経由で呼び出し、アプリの「GitHub同期」やカード操作と同じ処理でプロジェクトを更新する。
project.json を直接編集しないこと（ToDo への反映や親子関係の整合性はアプリのロジックに任せる）。

## CLI

```bash
A=~/.claude/skills/update-acta/scripts/acta.cjs
node $A pull                         # データリポジトリを git pull --rebase
node $A sync                         # GitHub同期（アプリの「GitHub同期」と同じ）
node $A projects                     # 既存プロジェクト一覧（未分類・アーカイブ除く、直近タスク名付き）
node $A unclassified                 # 未分類タスク + 本文抜粋 / リンク先Issue / 親Issue と Acta 上の所属
node $A pr-links                     # Open な PR タスクごとのリンク先 Issue と Acta 上の対応タスク
node $A create-project "<name>"      # プロジェクト作成
node $A reassign <taskId> <projectId>     # タスクを別プロジェクトへ移動
node $A set-parent <taskId> <parentTaskId> # 親タスクを設定（同一プロジェクト内のみ）
node $A move <taskId> <Backlog|InProgress|Done>
node $A delete <taskId>              # タスクを削除（ToDo からも消える）。ユーザーに頼まれたときのみ
node $A push                         # 変更をコミットして pull --rebase → push
```

出力はすべて JSON。`taskId` は GitHub 由来タスクなら GraphQL ノードID（`I_...` / `PR_...`）。

## 手順

### 0. 準備

1. `node $A pull` で最新化する。失敗（競合など）したら中断してユーザーに報告する
2. `node $A sync` を実行し、結果の `detail` を控える
   - `gh` 認証エラーの場合は `gh auth login`（Project 取得失敗なら `gh auth refresh -s read:project`）を案内して中断する

### 1. 未分類の振り分け

1. `node $A unclassified` と `node $A projects` を実行する。未分類が 0 件なら手順 2 へ
2. 各タスクの振り分け先を次の優先順で判断する
   1. `linkedIssues[].acta` / `parentIssue.acta` が既存プロジェクト（未分類以外）にあれば、そのプロジェクト
   2. タイトル・本文抜粋・リポジトリが既存プロジェクトの名前や `recentTasks` と同じテーマなら、そのプロジェクト
   3. 定常的な依頼・相談系（「インフラ相談/レビュー」、アカウント・権限の付与/削除、休職・退職処理など）は `SRE対応依頼`、どこにも当てはまらない小粒の作業は `その他`
   4. 上記に当てはまらず、明らかに独立したテーマ（新しい移行・導入・バージョンアップ等の案件）なら新規プロジェクト候補
3. 既存プロジェクトへの振り分けは確認なしで `reassign` してよい。判断に迷うものは無理に振り分けず未分類に残し、最後に報告する
4. 新規プロジェクト候補がある場合
   - 名前は既存プロジェクトに倣い、日本語で簡潔な案件名にする（例: `MySQLユーザーの権限整理`、`GitHub Enterprise移行`）。Issue タイトルの `#番号` や装飾は除く
   - 作成前に必ず AskUserQuestion で確認する（候補名・対象タスク・理由を提示し、「この名前で作成」「別名にする」「既存プロジェクトに入れる」「未分類のまま」などを選べるようにする）
   - 承認されたら `create-project` → 出力の `id` へ `reassign` する

### 2. PR に親 Issue を紐付けて InProgress へ

1. `node $A pr-links` を実行する
2. `linkedIssues` があり、そのうち `acta` が null でないものを親候補にする
   - 候補が複数なら、PR と同じプロジェクトにあるもの → より具体的な（子側の）Issue を優先する
   - リンク先 Issue が Acta に無い（`acta: null`）場合は紐付けをスキップし、報告に含める
3. 親 Issue が PR と別プロジェクトにある場合は、PR を親 Issue のプロジェクトへ `reassign` する（親子関係は同一プロジェクト内のみのため）
4. PR の `parentId` が親 Issue の `taskId` と異なれば `set-parent <PRのtaskId> <IssueのtaskId>`
5. PR の `status` が `Backlog` なら `move <PRのtaskId> InProgress`。親 Issue も `Backlog` なら同様に `InProgress` へ移動する
   - すでに `Done` のタスクは利用者が完了扱いにしたものなので動かさない

### 3. 保存と報告

1. 変更があれば `node $A push` で同期する（失敗したら結果をそのまま報告）
2. 次の形式で簡潔に報告する

```markdown
## Acta 更新結果

- 同期: <sync の detail>

### 未分類の振り分け
| タスク | 振り分け先 | 根拠 |
|---|---|---|

### PR の親 Issue 紐付け
| PR | 親 Issue | 状態変更 |
|---|---|---|

### 未対応
- <未分類に残したもの / Acta に無いリンク先 Issue など。無ければ省略>
```

## 注意

- 新規プロジェクトの作成は必ずユーザーの承認を得てから行う
- タスクの削除はユーザーに明示的に頼まれたときだけ行う。プロジェクトの削除・アーカイブはしない
- GitHub 上で Open のまま削除したタスクは次回の同期で再び取り込まれる
- マージせずクローズした PR、Not planned / Duplicate でクローズした Issue は、同期時に ToDo を完了にせず削除する
- 出力は日本語、絵文字なし
