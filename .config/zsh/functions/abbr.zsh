_abbr_session() {
  abbr -q erase -S "$1" >/dev/null 2>&1
  abbr -q -S "$1=$2"
}

### Main
_abbr_session .. 'cd ..'
_abbr_session awsvl 'aws-vault login'
_abbr_session bat 'bat -p --theme=Dracula'
_abbr_session bincat '/bin/cat'
_abbr_session binls '/bin/ls'
_abbr_session c 'clear'
_abbr_session cddownloads 'cd ~/Downloads'
_abbr_session cdworks 'cd ~/Works'
_abbr_session cp 'cp -vi'
_abbr_session date 'gdate'
_abbr_session ddd 'cd ~/Downloads'
_abbr_session cdr 'eval cd "$(dirs -v | fzf | awk '\''{print $2}'\'')"'
_abbr_session doc 'docker'
_abbr_session docc 'docker compose'
_abbr_session evc 'envchain'
_abbr_session history 'history 0'
_abbr_session ll 'eza -la --git --icons'
_abbr_session llr 'eza -lra --git --icons'
_abbr_session ls 'eza'
_abbr_session mv 'mv -vi'
_abbr_session rm 'rm -vi'
_abbr_session vi 'vim'
_abbr_session tmpdir2 'export TMPDIR2=$(mktemp -d) && cd $TMPDIR2'
_abbr_session cld 'claude --dangerously-skip-permissions'
_abbr_session cl 'claude'

### Terraform
_abbr_session tf 'terraform'
_abbr_session tfa 'terraform apply'
_abbr_session tff 'terraform fmt'
_abbr_session tfi 'terraform init'
_abbr_session tfp 'terraform plan'
_abbr_session tfv 'terraform validate'
_abbr_session tfc 'terraform console'
_abbr_session tfip 'terraform init && terraform plan'
_abbr_session tfifv 'terraform init && terraform fmt && terraform validate'
_abbr_session tfcheck 'terraform fmt && terraform validate && tflint'
_abbr_session tffp 'terraform state list | fzf --multi --preview "terraform state show {}" | sed "s/^/-target=/" | xargs terraform plan '
_abbr_session tffa 'terraform state list | fzf --multi --preview "terraform state show {}" | sed "s/^/-target=/" | xargs terraform apply '

### Git
_abbr_session g 'git'
_abbr_session gad 'git add -A'
_abbr_session gcm 'git commit'
_abbr_session gcmm 'git commit -m "%"'
_abbr_session gbrd 'git branch | fzf | xargs git branch -d '
_abbr_session gsw 'git branch | fzf | xargs git switch '
_abbr_session gst 'git status'
_abbr_session glg 'git log'
_abbr_session gdf 'git diff'
_abbr_session gcmb 'git add . && git commit -m "backup at $(date +%Y%m%d%H%M)" && git push'

### kubectl
# kubectl completion is expensive, so load it lazily on first direct invocation.
kubectl() {
  unfunction kubectl
  source <(command kubectl completion zsh)
  command kubectl "$@"
}

_abbr_session kc 'kubectl'

### tmux
_abbr_session tmk 'tmux kill-server'

### bundle
_abbr_session be 'bundle exec'
_abbr_session ber 'bundle exec rake'

### hub
_abbr_session ghl 'cd $(ghq root)/$(ghq list | fzf)'

### Python
_abbr_session py 'python'

unfunction _abbr_session
