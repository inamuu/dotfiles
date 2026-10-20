#!/bin/bash
# Claude Code の hook から macOS 通知を出す
# 使い方: notify-command.sh <notification|permission|stop>  (hook の JSON を stdin で受け取る)
# herdr 内なら workspace 名と番号、外ならリポジトリ名をタイトルに出す

kind="${1:-stop}"
input="$(cat)"

field() { printf '%s' "$input" | jq -r "$1 // empty" 2>/dev/null; }
# 改行を潰して指定文字数で切る
# (cut はロケール次第でマルチバイト文字を壊すので perl で文字単位に切る)
oneline() {
  perl -CSD -0777 -ne 's/\s+/ /g; s/^ | $//g; $n = '"${1:-120}"'; print length > $n ? substr($_, 0, $n) . "\x{2026}" : $_'
}

cwd="$(field .cwd)"
[ -n "$cwd" ] || cwd="$PWD"

# リポジトリ名とブランチ
repo="$(basename "$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null || echo "$cwd")")"
branch="$(git -C "$cwd" branch --show-current 2>/dev/null)"
location="$repo${branch:+ ($branch)}"

# herdr の workspace 名と番号
where="$location"
if [ "${HERDR_ENV:-}" = "1" ] && [ -n "${HERDR_WORKSPACE_ID:-}" ] && command -v herdr >/dev/null; then
  ws="$(herdr workspace get "$HERDR_WORKSPACE_ID" 2>/dev/null | jq -r '.result.workspace | "\(.label) #\(.number)"' 2>/dev/null)"
  [ -n "$ws" ] && where="$ws"
fi

# タイトル + 本文1行の2行に収める。文字色は変えられないため色付き絵文字で種類を見分ける
case "$kind" in
  notification)
    title="🟡 入力待ち · $where"
    message="$(field .message | oneline 40)"
    message="${message:-確認が必要です}"
    sound="Blow"
    ;;
  permission)
    tool="$(field .tool_name)"
    detail="$(field '.tool_input.command // .tool_input.file_path // .tool_input.url' | oneline 40)"
    title="🔴 許可待ち · $where"
    message="${tool:-tool}${detail:+: $detail}"
    sound="Blow"
    ;;
  *)
    title="🟢 完了 · $where"
    message="$(field .last_assistant_message | oneline 40)"
    message="${message:-タスクが完了しました}"
    sound="Glass"
    ;;
esac

# 文字列は argv で渡し、AppleScript への埋め込み時のエスケープ問題を避ける
osascript - "$title" "$message" "$sound" <<'EOF' >/dev/null 2>&1
on run argv
  display notification (item 2 of argv) with title (item 1 of argv) sound name (item 3 of argv)
end run
EOF
exit 0
