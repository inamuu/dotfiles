# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"

### link
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
[ -f ~/.zsh_functions ] && source ~/.zsh_functions

### powerlevel10k
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

### Terminal theme
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
  ZSH_THEME=""  # Disable Powerlevel10k for Cursor
else
  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
fi

### Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

alias history="history 0"

#ZSH_THEME="robbyrussell"
#ZSH_THEME="agnoster"
#ZSH_THEME="inamuu"
#ZSH_THEME="apple"
#ZSH_THEME="powerline"

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

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="yyyy/mm/dd"

### Binary Paths
export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH=$HOME/ghq/github.com/inamuu/tools:$PATH
# export MANPATH="/usr/local/man:$MANPATH" ### Common export EDITOR=vim

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

# http://mollifier.hatenablog.com/entry/20090728/p1
zshaddhistory() {
    local line=${1%%$'\n'} #コマンドライン全体から改行を除去したもの
    local cmd=${line%% *}  # １つ目のコマンド
    # 以下の条件をすべて満たすものだけをヒストリに追加する
    [[ ${#line} -ge 5
        && ${cmd} != (l|l[sal])
        && ${cmd} != (cd)
        && ${cmd} != (m|man)
        && ${cmd} != (r[mr])
        && ${cmd} != (terraform apply)
    ]]
}

### History
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
function history-all { history -E 1 }
setopt hist_ignore_dups

### powerline theme
#POWERLINE_HIDE_HOST_NAME="true"
#POWERLINE_SHORT_HOST_NAME="true"
#POWERLINE_HIDE_USER_NAME="true"
#POWERLINE_HIDE_GIT_PROMPT_STATUS="true"

### homebrew
export PATH=/opt/homebrew/bin:/opt/homebrew/sbin:$PATH
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

### peco
function pecor { peco --query "$LBUFFER" --layout=bottom-up }

### peco&ssh
function peco-ssh () {
  local selected_host=$(awk '
  tolower($1)=="host" {
    for (i=2; i<=NF; i++) {
      if ($i !~ "[*?]") {
        print $i
      }
    }
  }
  ' ~/.ssh/config ~/.ssh/**/config | sort | pecor)
  if [ -n "$selected_host" ]; then
    BUFFER="ssh -A ${selected_host}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-ssh
bindkey '^S' peco-ssh

### history
function peco-history-selection() {
    #BUFFER=`history | tail -r | awk '{$1="";print $0}' | peco`
    BUFFER=$(history | awk '{$1="";print $0}' | egrep -v "ls" | uniq -u | sed 's/^ //g' | pecor)
    CURSOR=$#BUFFER
    zle reset-prompt
}
zle -N peco-history-selection
bindkey '^R' peco-history-selection

### direnv
[ $commands[direnv] ] && eval "$(direnv hook zsh)"
PS1="${CUSTOM_PS1:-default PS1}: "

### Alias(Main)
alias ..='cd ..'
alias bat='bat -p --theme=Dracula'
alias bincat='/bin/cat'
alias binls='/bin/ls'
alias c='clear'
alias cddownloads='cd ~/Downloads'
alias cdworks='cd ~/Works'
alias cp='cp -vi'
alias date='gdate'
alias ddd='cd ~/Downloads'
alias cdr="eval cd \"\$(dirs -v | pecor | awk '{print \$2}')\""
alias doc='docker'
alias docc='docker compose'
alias evc='envchain'
alias ll='eza -la --git --icons'
alias llr='eza -lra --git --icons'
alias ls='eza'
alias mv='mv -vi'
alias rm='rm -vi'
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfinitplan='terraform init && terraform plan'
alias tfcheck='terraform fmt && terraform validate && tflint'
alias vi='vim'
export LESS='-i -M -R'

### Terraform
export TF_CLI_ARGS_plan="--parallelism=30"
export TF_CLI_ARGS_apply="--parallelism=30"

tfrun() {
  TARGET=$(egrep -h "(^module\s|^resource\s)" *tf | awk '{print $1"."$2}' | sed 's/"//g' | peco)
  CTL=$(echo "plan\napply" | peco)
  printf "Run terraform ${CTL} -target=${TARGET}\n"
  terraform ${CTL} -target=${TARGET}
}

tfmog() {
  [ $# -eq 0 ] && return 1
  TARGET_LIST=$(grep -E "^module|^resource" $1 | sed 's/"//g' |  awk '{print $1"."$2" "}' | egrep -v "null_resource")
  printf "### TARGET LIST \n${TARGET_LIST}\n"
  PLAN_LIST=$(echo ${TARGET_LIST} | awk '{print " -target="$1}' | gsed -e ':a;N;$!ba;s/\n//g' -e 's/"//g')
  printf "\n### Run terraform plan\nterraform plan $(echo ${PLAN_LIST})\n\n"
  terraform plan $(echo ${PLAN_LIST})
}

[ ! -d "${HOME}/.config/terraform/logs/$(date +%Y/%m/%d/)" ] && mkdir -p ${HOME}/.config/terraform/logs/$(date +%Y/%m/%d/)
export TF_LOG=ERROR
export TF_LOG_PATH=${HOME}/.config/terraform/logs/$(date +%Y/%m/%d)/terraform.$(date +%Y%m%d%H%M%S).log

### Notification
noti() {
  #osascript -e "display dialog \"${1:-なにか終わったよ}\" buttons {'OK'} default button \"OK\""
  osascript -e "display dialog \"${1:-処理が完了しました!}\" buttons {\"OK\"} default button \"OK\""
}

### Alias(Git)
alias g='git'
alias gbrd='git branch | grep -v -e "main" -e "*" | awk "{print $1}" | pecor | xargs git branch -d'
alias gsw='git branch | grep -v -e "*" | awk "{print $1}" | pecor | xargs git switch'

### Alias(kubectl)
source <(kubectl completion zsh)
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
alias ghl='cd $(ghq root)/$(ghq list | pecor)'

### anyenv
export ANYENV_ROOT="$HOME/.anyenv"
export PATH="$ANYENV_ROOT/bin:$PATH"
eval "$(anyenv init -)"

### Python
alias py='python'
export PYENV_ROOT="$HOME/.anyenv/envs/pyenv/versions/version"
export PATH="$PYENV_ROOT/shims:$PATH"
[ $commands[pyenv] ] && eval "$(pyenv init -)"

### Ruby
[ $commands[rbenv] ] && PATH=~/.rbenv/shims:"$PATH"

### Go
export GOPATH=$HOME/.anyenv/envs/goenv/shims/
#export GOPATH=$HOME/go/
export PATH=$GOROOT/bin:$PATH
eval "$(goenv init -)"

### Node
export NODENV_ROOT=$HOME/.anyenv/envs/nodenv
export NODENV_SHELL=zsh

### ESC Timeout
# http://lazy-dog.hatenablog.com/entry/2015/12/24/001648
KEYTIMEOUT=0

### google cloud
export PATH="$HOME/google-cloud-sdk/bin:$PATH"
if [ -f "${HOME}/google-cloud-sdk/path.zsh.inc" ]; then . "${HOME}/google-cloud-sdk/path.zsh.inc" ; fi
if [ -f "${HOME}/google-cloud-sdk/completion.zsh.inc" ]; then . "${HOME}/google-cloud-sdk/completion.zsh.inc" ; fi

### iTerm2
# comment out 20250430
#if [ -f "${HOME}/.iterm2_shell_integration.zsh" ]; then
# source "${HOME}/.iterm2_shell_integration.zsh"
# source ~/.iterm2_shell_integration.`basename $SHELL`
#fi
#
#function iterm2_print_user_vars() {
#    iterm2_set_user_var gitBranch $((git branch 2> /dev/null) | grep \* | cut -c3-)
#}

### GitHub
export GPG_TTY=$(tty)

### mise
if [ "${PCENV}" != "private" ]; then
  eval "$(mise activate zsh)"
fi

# Amazon Q post block. Keep at the bottom of this file.
# CursorでShellが止まってしまうので分岐
# https://zenn.dev/kikagaku/articles/cursor-agent-mode-hangs
if [[ "$AGENT_MODE" != "true" ]]; then
  [[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"
fi

