---
name: pr-review-request
description: Draft PR を Ready for review にし、レビュワーをそろえてコメントでレビューを依頼する。自動アサイン（CODEOWNERS 等）がある場合はその人たちに、ない場合は関連しそうな人と hpf_cto_sre チームを Reviewers に追加してから依頼する。「レビュー依頼して」「Draft を外してレビューに出して」と頼まれたとき、および /pr-review-request と入力されたときに使用する。
---

# pr-review-request - Draft 解除とレビュー依頼

## 対象 PR

- 引数に PR 番号か URL があればそれを使う。なければカレントブランチの PR（`gh pr view`）。
- worktree で作業している場合は、その worktree のディレクトリでコマンドを実行する。
- 以降、`<repo>` は `gh repo view --json nameWithOwner -q .nameWithOwner`、`<me>` は `gh api user -q .login`。

## 手順

### 1. Draft を解除する

```bash
gh pr ready <PR>
```

既に Draft でなければそのまま次へ進む。

### 2. 自動アサインの有無を確認する

Draft 解除で CODEOWNERS などによりレビュワーが自動で付くことがあるため、解除後に数秒おきに最大 30 秒ほど確認する。

```bash
gh api repos/<repo>/pulls/<番号>/requested_reviewers --jq '{users: [.users[].login], teams: [.teams[].slug]}'
```

- users または teams が 1 件以上ある → 手順 3（自動アサインあり）
- どちらも空 → 手順 4（自動アサインなし）

チームが付いている場合、GitHub のチーム自動割り当てでメンバー個人に置き換わるまで少し待つ。置き換わらないチームはメンションの対象にしない。

### 3. 自動アサインありの場合

自動で付いた個人レビュワー（自分を除く）にコメントで依頼する。想定人数は 2 人。人数が違う場合はユーザーに伝えたうえで、付いている人に依頼する。

### 4. 自動アサインなしの場合

#### 4-1. 関連しそうな人を 1 人選ぶ

次の材料から候補を出す（自分と bot は除く）。

- 変更ファイルの直近のコミット作者: `gh pr diff <PR> --name-only` のファイルに対して `git log -n 20 --format='%an <%ae>' -- <file>` を見る。GitHub の login は `gh api repos/<repo>/commits?path=<file>&per_page=20 --jq '.[].author.login'` で取る
- PR 本文で参照している issue の作成者・担当者・コメントした人
- 関連 PR のレビュワー

候補と選んだ理由をユーザーに示し、AskUserQuestion で 1 人を確定させてから追加する（レビュワーの追加は相手に通知が飛ぶため）。

#### 4-2. Reviewers に追加する

```bash
gh pr edit <PR> --add-reviewer <関連する人>,medley-inc/hpf_cto_sre
```

#### 4-3. チームの自動選定を待つ

hpf_cto_sre はチームの自動割り当てでメンバー個人が選ばれる。手順 2 のコマンドで、teams からチームが消えて users に個人が入るまで数秒おきに最大 60 秒ほど待つ。

#### 4-4. 人数を確認する

依頼する人数は次のとおり。

| 関連する人 | 依頼人数 |
|---|---|
| hpf_cto_sre のメンバー | 2 人 |
| それ以外 | 3 人 |

SRE メンバーは `gh api orgs/medley-inc/teams/hpf_cto_sre/members --jq '.[].login'` で判定する。実際の人数が表と違う場合（自動選定が完了しない、自分が選ばれて除外された等）はユーザーに伝え、付いている人に依頼する。

### 5. コメントでレビューを依頼する

自分を除く個人レビュワー全員をメンションする。メンションは実在する login のみを書く。

```bash
gh pr comment <PR> --body "@user1 @user2 レビューをお願いします。"
```

PR の内容を 1 行で添えてよい。長い説明は書かない（本文にあるため）。

### 6. 完了

PR の URL、依頼した人、どちらのケース（自動アサインあり / なし）だったかを短く報告する。

## 注意

- 自分（`<me>`）はメンションしない
- チームそのもの（`@medley-inc/hpf_cto_sre`）はメンションしない。メンバー全員に通知が飛ぶため
- Draft 解除・レビュワー追加・コメントは取り消しにくい操作なので、対象 PR を取り違えていないか最初に `gh pr view <PR> --json title,url,isDraft` で確認する
