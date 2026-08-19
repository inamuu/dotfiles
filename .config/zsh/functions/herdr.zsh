### herdr

# 直前のコマンド出力だけをクリップボードへコピーする
# 引数でペインIDを指定可能（省略時は自分のペイン、無ければフォーカス中のペイン）
# 例: herdr_lastout / herdr_lastout w4D:p2
herdr_lastout () {
  local PATH="/opt/homebrew/bin:$PATH"
  local pane="${1:-${HERDR_PANE_ID:-$(herdr pane list | jq -r '.result.panes[] | select(.focused) | .pane_id')}}"
  [[ -z "$pane" ]] && { print -u2 "herdr_lastout: 対象ペインが見つかりません"; return 1 }

  # プロンプト行の判定（starship: "mac:inamuu in ..."）
  local prompt_re="${HERDR_PROMPT_RE:-^[[:alnum:]_.-]+:[[:alnum:]_.-]+ in }"

  herdr pane read "$pane" --source recent-unwrapped --lines "${HERDR_READ_LINES:-3000}" \
  | awk -v re="$prompt_re" '
      { line[NR] = $0; if ($0 ~ re) { n++; idx[n] = NR } }
      END {
        # プロンプトが1つしか無い場合は全体を出す
        if (n < 2) { for (i = 1; i <= NR; i++) print line[i]; exit }
        # 直前のプロンプト行と "> コマンド" 行をスキップし、次のプロンプト手前まで
        for (i = idx[n-1] + 2; i <= idx[n] - 1; i++) print line[i]
      }' \
  | pbcopy
}

# Ctrl+X Ctrl+Y で直前の出力をコピー
herdr_lastout_widget () {
  herdr_lastout && zle -M "herdr: 直前の出力をコピーしました ($(pbpaste | wc -l | tr -d ' ') 行)"
}

zle -N herdr_lastout_widget
bindkey '^X^Y' herdr_lastout_widget
