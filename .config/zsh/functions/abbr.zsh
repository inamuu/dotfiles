### Main
abbr -qq -S -f '..=cd ..'
abbr -qq -S -f 'avl=aws-vault login'
abbr -qq -S -f 'asl=aws sso login'
abbr -qq -S -f 'bat=bat -p --theme=Dracula'
abbr -qq -S -f 'bincat=/bin/cat'
abbr -qq -S -f 'binls=/bin/ls'
abbr -qq -S -f 'c=clear'
abbr -qq -S -f 'cddl=cd ~/Downloads'
abbr -qq -S -f 'cdworks=cd ~/Works'
abbr -qq -S -f 'cp=cp -vi'
abbr -qq -S -f 'date=gdate'
abbr -qq -S -f 'cdr=eval cd "$(dirs -v | fzf | awk '\''{print $2}'\'')"'
abbr -qq -S -f 'doc=docker'
abbr -qq -S -f 'docc=docker compose'
abbr -qq -S -f 'evc=envchain'
abbr -qq -S -f 'history=history 0'
abbr -qq -S -f 'll=eza -la --git --icons'
abbr -qq -S -f 'llr=eza -lra --git --icons'
abbr -qq -S -f 'ls=eza'
abbr -qq -S -f 'mv=mv -vi'
abbr -qq -S -f 'rm=rm -vi'
abbr -qq -S -f 'vi=vim'
abbr -qq -S -f 'tmpdir2=export TMPDIR2=$(mktemp -d) && cd $TMPDIR2'
abbr -qq -S -f 'cld=claude --dangerously-skip-permissions'
abbr -qq -S -f 'cl=claude'
abbr -qq -S -f 'cxf=codex --full-auto'
abbr -qq -S -f 'cxn=codex -n never'

### Terraform
abbr -qq -S -f 'tf=terraform'
abbr -qq -S -f 'tfa=terraform apply'
abbr -qq -S -f 'tff=terraform fmt'
abbr -qq -S -f 'tfi=terraform init'
abbr -qq -S -f 'tfp=terraform plan'
abbr -qq -S -f 'tfv=terraform validate'
abbr -qq -S -f 'tfc=terraform console'
abbr -qq -S -f 'tfip=terraform init && terraform plan'
abbr -qq -S -f 'tfif=terraform init && terraform fmt'
abbr -qq -S -f 'tfifv=terraform init && terraform fmt && terraform validate'
abbr -qq -S -f 'tfcheck=terraform fmt && terraform validate && tflint'
abbr -qq -S -f 'tffp=terraform state list | fzf --multi --preview "terraform state show {}" | sed "s/^/-target=/" | xargs terraform plan '
abbr -qq -S -f 'tffa=terraform state list | fzf --multi --preview "terraform state show {}" | sed "s/^/-target=/" | xargs terraform apply '

### Git
[[ -f "${HOME}/.gitconfig" ]] && abbr -qq -S -f import-git-aliases --file "${HOME}/.gitconfig" --prefix g

# .gitconfigがあれば展開はされるけどzsh上定義しておかないと
# 存在しないコマンドとして赤色になるのでそれをさけるために定義
abbr -qq -S -f 'g=git'
abbr -qq -S -f 'gad=git add .'
abbr -qq -S -f 'gaa=git add -A'
abbr -qq -S -f 'gst=git status'
abbr -qq -S -f 'glg=git log'
abbr -qq -S -f 'gdf=git diff'
abbr -qq -S -f 'gpl=git pull --prune'
abbr -qq -S -f 'gpl=git push -u origin'
abbr -qq -S -f 'ghpc=gh pr create -d'
abbr -qq -S -f 'ghpv=gh pr view -w'
abbr -qq -S -f 'ghrv=gh repo view -w'
abbr -qq -S -f 'gcmm=git commit -m "%ABBR_CURSOR%"'
abbr -qq -S -f 'gbrd=git branch | fzf | xargs git branch -d '
abbr -qq -S -f 'gcmb=git add . && git commit -m "backup at $(date +%Y%m%d%H%M)" && git push'
abbr -qq -S -f 'tt=echo "%ABBR_CURSOR%"'

### kubectl
# kubectl completion is expensive, so load it lazily on first direct invocation.
kubectl() {
  unfunction kubectl
  source <(command kubectl completion zsh)
  command kubectl "$@"
}

abbr -qq -S -f 'kc=kubectl'

### tmux
abbr -qq -S -f 'tmk=tmux kill-server'

### bundle
abbr -qq -S -f 'be=bundle exec'
abbr -qq -S -f 'ber=bundle exec rake'

### hub
abbr -qq -S -f 'ghl=cd $(ghq root)/$(ghq list | fzf)'

### Python
abbr -qq -S -f 'py=python'
