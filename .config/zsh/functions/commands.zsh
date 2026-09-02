### Main
cdr() {
  local dir

  dir=$(dirs -v | fzf | awk '{print $2}')
  [[ -n "${dir}" ]] || return 0
  builtin cd "${dir}"
}

tmpdir2() {
  export TMPDIR2="$(mktemp -d)" || return 1
  builtin cd "${TMPDIR2}"
}

### Terraform
tfip() {
  terraform init && terraform plan "$@"
}

tfif() {
  terraform init && terraform fmt "$@"
}

tfifv() {
  terraform init && terraform fmt && terraform validate "$@"
}

tfcheck() {
  terraform fmt && terraform validate && tflint "$@"
}

tffp() {
  local -a selected targets

  selected=("${(@f)$(terraform state list | fzf --multi --preview 'terraform state show {}')}")
  (( ${#selected[@]} )) || return 0

  targets=("${selected[@]/#/-target=}")
  terraform plan "${targets[@]}" "$@"
}

tffa() {
  local -a selected targets

  selected=("${(@f)$(terraform state list | fzf --multi --preview 'terraform state show {}')}")
  (( ${#selected[@]} )) || return 0

  targets=("${selected[@]/#/-target=}")
  terraform apply "${targets[@]}" "$@"
}

### Git
# worktree のルートディレクトリ。メインの worktree 名を元にした ~/worktrees/<repo>_<name> を使う。
_gwt_repo_name() {
  local common_dir main_dir

  common_dir=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || return 1
  main_dir=${common_dir:h}
  print -r -- "${main_dir:t}"
}

_gwt_paths() {
  git worktree list --porcelain | awk '/^worktree /{print $2}'
}

gwtadd() {
  local name=${1:?usage: gwtadd <name> [base]}
  local base=${2:-HEAD}
  # path は zsh の特殊変数（PATH）なので使わない。
  local repo_name wt_path

  repo_name=$(_gwt_repo_name) || return 1
  wt_path="${HOME}/worktrees/${repo_name}_${name}"

  if git show-ref --verify --quiet "refs/heads/${name}"; then
    git worktree add "${wt_path}" "${name}"
  else
    git worktree add -b "${name}" "${wt_path}" "${base}"
  fi
}

gwtls() {
  git worktree list "$@"
}

gwtremove() {
  local target

  target=${1:-$(_gwt_paths | tail -n +2 | fzf)}
  [[ -n "${target}" ]] || return 0
  git worktree remove "${target}"
}

gwtcd() {
  local target

  target=${1:-$(_gwt_paths | fzf)}
  [[ -n "${target}" ]] || return 0
  builtin cd "${target}"
}

# gwtadd/gwtls/gwtcd/gwtremove をサブコマンド形式でも使えるようにしたもの。
gwt() {
  local subcmd=${1:-}
  (( $# )) && shift

  case "${subcmd}" in
    add|a)       gwtadd "$@" ;;
    ls|list|l)   gwtls "$@" ;;
    cd|c)        gwtcd "$@" ;;
    rm|remove|r) gwtremove "$@" ;;
    ""|help|-h|--help)
      cat <<'USAGE'
usage: gwt <command> [args]

  add <name> [base]  ブランチと worktree を作成する（既存ブランチならそれを使う）
  ls                 worktree を一覧表示する
  cd [path]          worktree に移動する（省略時は fzf で選択）
  rm [path]          worktree を削除する（省略時は fzf で選択）
USAGE
      ;;
    *)
      print -u2 "gwt: unknown command: ${subcmd}"
      return 1
      ;;
  esac
}

_gwt() {
  local -a subcmds
  subcmds=(
    'add:ブランチと worktree を作成する'
    'ls:worktree を一覧表示する'
    'cd:worktree に移動する'
    'rm:worktree を削除する'
  )

  if (( CURRENT == 2 )); then
    _describe 'gwt command' subcmds
    return
  fi

  case "${words[2]}" in
    cd|c|rm|remove|r) _values 'worktree' ${(f)"$(_gwt_paths)"} ;;
    add|a)            (( CURRENT == 4 )) && _git_branch_names ;;
  esac
}
# compinit 前に読み込まれる場合があるため compdef の有無を確認する。
(( $+functions[compdef] )) && compdef _gwt gwt

gswitch() {
  local branch

  if [[ $# -gt 0 ]]; then
    git switch "$@"
    return
  fi

  branch=$(git branch --format='%(refname:short)' | fzf)
  [[ -n "${branch}" ]] || return 0
  git switch "${branch}"
}

gbrd() {
  local branch

  branch=$(git branch --format='%(refname:short)' | fzf)
  [[ -n "${branch}" ]] || return 0
  git branch -d "${branch}"
}

gcmb() {
  local stamp

  stamp=$(date +%Y%m%d%H%M)
  git add . && git commit -m "backup at ${stamp}" && git push
}

### kubectl
# kubectl completion is expensive, so load it lazily on first direct invocation.
kubectl() {
  unfunction kubectl
  source <(command kubectl completion zsh)
  command kubectl "$@"
}

### hub
ghl() {
  local repo

  repo=$(ghq list | fzf)
  [[ -n "${repo}" ]] || return 0
  builtin cd "$(ghq root)/${repo}"
}
