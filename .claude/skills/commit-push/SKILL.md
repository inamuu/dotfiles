---
name: commit-push
description: git diff に秘匿情報（APIキー、トークン、パスワード、秘密鍵、個人情報など）が含まれていないかをチェックしてから commit & push する。「コミットして」「コミットしてプッシュして」「秘匿情報をチェックしてコミット」と頼まれたとき、および /commit-push と入力されたときに使用する。
---

# commit-push - 秘匿情報チェック付き commit & push

コミット対象の差分をスキャンし、秘匿情報が無いことを確認してから commit & push する。

## 手順

### 1. 現状確認

```bash
git status --short
git branch --show-current
git diff            # unstaged
git diff --staged   # staged
```

- **master / main に直接コミットしない。** カレントブランチがデフォルトブランチの場合は、作業ブランチを切るかユーザーに確認する。
- ステージ済みの変更がある場合はそれを対象とする。無い場合はユーザーの意図した範囲を確認してから `git add` する。
- `git add -A` は無関係なファイルを巻き込むため、原則ファイルを明示して add する。

### 2. 秘匿情報チェック（必須）

チェック対象は **これから commit する差分の追加行のみ**（`^\+`）。

```bash
git diff --staged | rg -n '^\+' | rg -i -n \
  -e 'aws_?(secret|access)_?key' \
  -e 'AKIA[0-9A-Z]{16}' \
  -e 'ASIA[0-9A-Z]{16}' \
  -e '(api|secret|private|access)[-_ ]?(key|token|secret)\s*[:=]' \
  -e 'password\s*[:=]' \
  -e 'passwd\s*[:=]' \
  -e 'BEGIN [A-Z ]*PRIVATE KEY' \
  -e 'gh[pousr]_[A-Za-z0-9]{20,}' \
  -e 'xox[baprs]-[A-Za-z0-9-]{10,}' \
  -e 'sk-[A-Za-z0-9]{20,}' \
  -e 'sk-ant-[A-Za-z0-9_-]{20,}' \
  -e 'eyJ[A-Za-z0-9_-]{20,}\.' \
  -e 'Authorization:\s*(Bearer|Basic)\s+\S+' \
  -e 'https?://[^/\s]*:[^@/\s]+@' \
  -e '[0-9]{12}' \
  -e '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'
```

さらに以下も併せて確認する。

- 追加されたファイル名: `.env`, `*.pem`, `*.key`, `*.p12`, `id_rsa`, `credentials`, `*.tfstate`, `*.tfvars`（`*.tfvars.example` は除く）
- 差分の目視確認（正規表現に引っかからない秘匿情報もある。IPアドレス、社内ホスト名、顧客名、URLトークンなど）

### 3. 検出時の扱い

- ヒットしたら **コミットせずに停止** し、ファイル名・行・該当箇所（値はマスクして表示）をユーザーに報告して指示を仰ぐ。
- 誤検知（サンプル値、ダミー、`example.com`、プレースホルダ、既存コードのコピー）と判断できる場合は、その理由を1行で示したうえで続行してよい。
- 秘匿情報が本物だった場合は、値を環境変数や 1Password などの外部管理へ移す方法を提案する。
- **勝手に値を書き換えたりファイルを削除したりしない。**

### 4. commit

```bash
git add <ファイル>
git commit -m "<日本語のコミットメッセージ>"
```

- コミットメッセージは日本語、1行で変更内容が分かるように書く。
- 既存コミットのスタイル（`git log --oneline -10`）に合わせる。
- Co-Authored-By 行は既存リポジトリの慣習に従う（dotfiles など個人リポジトリでは不要）。

### 5. push

```bash
git push origin <ブランチ名>
```

- 初回 push のブランチは `git push -u origin <ブランチ名>`。
- `--force` は使わない。必要な場合は必ずユーザーに確認し、`--force-with-lease` を使う。

### 6. 完了報告

- コミットハッシュ、メッセージ、push 先ブランチを1〜3行で報告する。
- 秘匿情報チェックの結果（検出なし / 誤検知として続行）も1行で添える。

## 注意

- 秘匿情報チェックは **必ず commit の前** に行う。push 済みの秘匿情報は取り消せない。
- チェックをスキップしてよいのは、ユーザーが明示的にスキップを指示した場合のみ。
- リポジトリに `.gitleaks.toml` や pre-commit の secret スキャナがある場合はそちらも実行する。
- 検出した秘匿情報の値そのものを、報告や後続の出力にフルで書き出さない（先頭数文字＋マスク）。
