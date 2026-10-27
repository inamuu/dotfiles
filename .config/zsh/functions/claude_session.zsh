### Claude Code セッション再開
# /savesession で保存した引き継ぎファイルを fzf で選び、その作業ディレクトリで再開する
# ccr    : status: open のものから選んで、引き継ぎファイルを読み込ませた新規セッションで再開
# ccr -a : done も含めて表示
# ccr -s : 引き継ぎではなく元のセッション（session_id）をそのまま --resume で再開
ccr() {
  local dir="${HOME}/Google Drive/マイドライブ/LLM/ClaudeCode/Sessions"
  local all=0 orig=0 opt
  while getopts "as" opt; do
    case "${opt}" in
      a) all=1 ;;
      s) orig=1 ;;
      *) return 1 ;;
    esac
  done

  local files=("${dir}"/*.md(N))
  (( ${#files} )) || { echo "引き継ぎファイルがありません: ${dir}"; return 1; }

  # 一覧: updated <TAB> status <TAB> title <TAB> path（frontmatter から抽出、新しい順）
  local line
  line=$(awk -v all="${all}" '
    FNR == 1 { fm = 0; t = s = u = "" }
    /^---$/ { fm++; if (fm == 2 && (all || s != "done")) printf "%s\t%s\t%s\t%s\n", u, s, t, FILENAME; next }
    fm == 1 && /^title:/   { sub(/^title:[ ]*/, "");   t = $0 }
    fm == 1 && /^status:/  { sub(/^status:[ ]*/, "");  s = $0 }
    fm == 1 && /^updated:/ { sub(/^updated:[ ]*/, ""); u = $0 }
  ' "${files[@]}" | sort -r | fzf --delimiter='\t' --with-nth=1,2,3 --preview 'cat {4}' --preview-window=right:60%:wrap)
  [[ -n "${line}" ]] || return 0

  local file="${line##*$'\t'}"
  _ccr_get() { awk -v k="$1" 'index($0, k ":") == 1 { sub(/^[^:]*:[ ]*/, ""); print; exit }' "$2" }
  local title=$(_ccr_get title "${file}")
  local cwd=$(_ccr_get cwd "${file}")
  local repo=$(_ccr_get repo "${file}")
  local sid=$(_ccr_get session_id "${file}")

  # 別 PC などで cwd が無い場合は ghq のリポジトリで代替する
  if [[ ! -d "${cwd}" && -n "${repo}" ]]; then
    cwd=$(ghq list -p -e "${repo}" 2>/dev/null)
  fi
  if [[ -d "${cwd}" ]]; then
    builtin cd "${cwd}"
  else
    echo "作業ディレクトリが見つからないため現在地で再開します"
  fi

  if (( orig )) && [[ -n "${sid}" ]]; then
    claude --resume "${sid}"
  else
    claude -n "${title}" "引き継ぎファイル ${file} を読み込み、「次にやること」から作業を再開して。着手前に現状と次の一手を3行以内で示すこと。このセッションで /savesession したら同じファイルを更新すること。"
  fi
}
