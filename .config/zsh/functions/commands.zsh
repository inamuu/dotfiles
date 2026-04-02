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
gwtadd() {
  local name=${1:?usage: gwta <name> [base]}
  local base=${2:-HEAD}
  local repo_name=${${PWD:A:t}}

  git worktree add -b "${name}" "../${repo_name}_${name}" "${base}"
}

gwtremove() {
  local target

  target=${1:-$(git worktree list --porcelain | awk '/^worktree /{print $2}' | tail -n +2 | fzf)}
  [[ -n "${target}" ]] || return 0
  git worktree remove "${target}"
}

gwtcd() {
  local target

  target=${1:-$(git worktree list --porcelain | awk '/^worktree /{print $2}' | fzf)}
  [[ -n "${target}" ]] || return 0
  builtin cd "${target}"
}

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
