### Git worktree
# wt <branch> : worktree を作成して移動（作成済みならそのまま移動）
# wt          : ~/worktrees 配下から fzf で選んで移動（リポジトリ外からでも可）
wt() {
  local root="${HOME}/worktrees"
  local dir

  if [[ -n "$1" ]]; then
    local repo
    repo=$(basename "$(git rev-parse --show-toplevel)") || return 1
    dir="${root}/${repo}/$1"
    [[ -d "${dir}" ]] || git wt "$1" || return 1
  else
    dir=$(find "${root}" -mindepth 3 -maxdepth 5 -name .git -type f 2>/dev/null | sed 's|/\.git$||' | fzf)
    [[ -n "${dir}" ]] || return 0
  fi

  builtin cd "${dir}"
}
