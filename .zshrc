### PATHを追加
export PATH=/opt/homebrew/bin:/opt/homebrew/sbin:$PATH
export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH=$HOME/ghq/github.com/inamuu/tools:$PATH

### XDG base dirs (defaults)
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_DATA_HOME="$HOME/.local/share"

### XDG history/cache
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export LESSHISTFILE="$XDG_STATE_HOME/less/history"
export MYSQL_HISTFILE="$XDG_DATA_HOME/mysql_history"
export ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"

[[ -d "$XDG_STATE_HOME/zsh" ]] || mkdir -p "$XDG_STATE_HOME/zsh"
[[ -d "$XDG_STATE_HOME/less" ]] || mkdir -p "$XDG_STATE_HOME/less"
[[ -d "$XDG_CACHE_HOME/zsh" ]] || mkdir -p "$XDG_CACHE_HOME/zsh"

### Kiro CLI, pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh"

### zshのローカルファイル読み込み
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

for file in ${HOME}/.config/zsh/functions/*.zsh(N);do
  source "$file"
done

source ${HOME}/.config/zsh/wezterm/wezterm.sh

# シンタックスハイライト有効化
source /opt/homebrew/opt/zsh-syntax-highlighting/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# サジェスト有効化
source /opt/homebrew/opt/zsh-autosuggestions/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to change how often to auto-update (in days).
export UPDATE_ZSH_DAYS=13

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

### 区切り文字: default "*?_-.[]~&;!#$%^(){}<>"
export WORDCHARS=""

### not like emacs keybind in terminal
bindkey -e

export LANG=ja_JP.UTF-8
setopt print_eight_bit
setopt auto_cd
setopt no_beep
setopt nolistbeep
setopt auto_pushd
setopt pushd_ignore_dups
setopt hist_ignore_dups     # 前と重複する行は記録しない
setopt share_history        # 同時に起動したzshの間でヒストリを共有する
setopt hist_reduce_blanks   # 余分なスペースを削除してヒストリに保存する
setopt HIST_IGNORE_SPACE    # 行頭がスペースのコマンドは記録しない
setopt HIST_IGNORE_ALL_DUPS # 履歴中の重複行をファイル記録前に無くす
setopt HIST_FIND_NO_DUPS    # 履歴検索中、(連続してなくとも)重複を飛ばす
setopt HIST_NO_STORE        # histroyコマンドは記録しない

### homebrew
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
export HOMEBREW_BUNDLE_FILE="${HOME}/.config/homebrew/Brewfile"

### direnv
[ $commands[direnv] ] && eval "$(direnv hook zsh)"
PS1="${CUSTOM_PS1:-default PS1}: "

### Alias(Main)
alias ..='cd ..'
alias awsvl='aws-vault login'
alias bat='bat -p --theme=Dracula'
alias bincat='/bin/cat'
alias binls='/bin/ls'
alias c='clear'
alias cddownloads='cd ~/Downloads'
alias cdworks='cd ~/Works'
alias cp='cp -vi'
alias date='gdate'
alias ddd='cd ~/Downloads'
alias cdr="eval cd \"\$(dirs -v | fzf | awk '{print \$2}')\""
alias doc='docker'
alias docc='docker compose'
alias evc='envchain'
alias history='history 0'
alias ll='eza -la --git --icons'
alias llr='eza -lra --git --icons'
alias ls='eza'
alias mv='mv -vi'
#alias rg='rg --hidden'
alias rm='rm -vi'
alias vi='vim'
alias tmpdir2='export TMPDIR2=$(mktemp -d) && cd $TMPDIR2'
alias cld='claude --dangerously-skip-permissions'
alias cl='claude'

export LESS='-i -M -R'

### Terraform
export TF_CLI_CONFIG_FILE="$XDG_CONFIG_HOME/terraform/terraformrc"
export TF_CLI_ARGS_plan="--parallelism=30"
export TF_CLI_ARGS_apply="--parallelism=30"

alias tf='terraform'
alias tfa='terraform apply'
alias tff='terraform fmt'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfv='terraform validate'
alias tfc='terraform console'
alias tfip='terraform init && terraform plan'
alias tfifv='terraform init && terraform fmt && terraform validate'
alias tfcheck='terraform fmt && terraform validate && tflint'

tfmog() {
  [ $# -eq 0 ] && return 1
  TARGET_LIST=$(grep -E "^module|^resource" $1 | sed 's/"//g' |  awk '{print $1"."$2" "}' | egrep -v "null_resource")
  printf "### TARGET LIST \n${TARGET_LIST}\n"
  PLAN_LIST=$(echo ${TARGET_LIST} | awk '{print " -target="$1}' | gsed -e ':a;N;$!ba;s/\n//g' -e 's/"//g')
  printf "\n### Run terraform plan\nterraform plan $(echo ${PLAN_LIST})\n\n"
  terraform plan $(echo ${PLAN_LIST})
}

alias tffp='terraform state list | fzf --multi --preview "terraform state show {}" | sed "s/^/-target=/" | xargs terraform plan '
alias tffa='terraform state list | fzf --multi --preview "terraform state show {}" | sed "s/^/-target=/" | xargs terraform apply '

### terraform logs
[ ! -d "$XDG_CONFIG_HOME/terraform/logs/$(date +%Y/%m/%d/)" ] && mkdir -p $XDG_CONFIG_HOME/terraform/logs/$(date +%Y/%m/%d/)
export TF_LOG=ERROR
export TF_LOG_PATH=$XDG_CONFIG_HOME/terraform/logs/$(date +%Y/%m/%d)/terraform.$(date +%Y%m%d%H%M%S).log

### Alias(Git)
alias g='git'
alias gbrd='git branch | fzf | xargs git branch -d '
alias gsw='git branch | fzf | xargs git switch '

### Alias(kubectl)
# kubectl completionは重いので遅延読み込みに変更
if [ $commands[kubectl] ]; then
  alias kubectl='function _kubectl(){ unalias kubectl; unfunction _kubectl; source <(kubectl completion zsh); kubectl "$@"; }; _kubectl'
fi
alias kc=kubectl

# colorize kubectl diff
export KUBECTL_EXTERNAL_DIFF="colordiff -N -u"

### tmux
#[[ -z "$TMUX" ]] && tmux || tmux a -t 0
alias tmk='tmux kill-server'

### bundle
alias be='bundle exec'
alias ber='bundle exec rake'

### hub
alias ghl='cd $(ghq root)/$(ghq list | fzf)'

### Python
alias py='python'

### Node
export NODENV_SHELL=zsh

### ESC Timeout
# http://lazy-dog.hatenablog.com/entry/2015/12/24/001648
KEYTIMEOUT=0

### google cloud
export PATH="$HOME/google-cloud-sdk/bin:$PATH"
if [ -f "${HOME}/google-cloud-sdk/path.zsh.inc" ]; then . "${HOME}/google-cloud-sdk/path.zsh.inc" ; fi
if [ -f "${HOME}/google-cloud-sdk/completion.zsh.inc" ]; then . "${HOME}/google-cloud-sdk/completion.zsh.inc" ; fi

### GitHub
export GPG_TTY=$(tty)

### mise
eval "$(mise activate zsh)"

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh"

### startshipの読み込み (kiro-cliの後に実行する必要がある)
eval "$(starship init zsh)"

