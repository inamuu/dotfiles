# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/bashrc.pre.bash" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/bashrc.pre.bash"
### Common
parse_git_branch(){
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

NAME="inamuu"
#export PS1="\[\e[36m\][$HOSTNAME \[\e[31m\]\W\[\e[36m\] ]\[\e[0;36m\]\$(parse_git_branch) \e[0;32m\]\\$ \[\e[0;00m\]"
export TERM=xterm-256color

### History
export HISTIGNORE="history*:ls -la*"
export HISTTIMEFORMAT='%Y%m%d %T '

### bash command
alias ls='ls -lG --color=auto'
alias ll='ls -laG --color=auto'
alias rm='rm -vi'
alias mv='mv -vi'
alias cp='cp -vi'
alias ..='cd ..'
alias vi='vim'
alias c='clear'

### hub
# alias g='cd $(ghq root)/$(ghq list | peco)'
alias gh='hub browse $(ghq list | peco | cut -d "/" -f 2,3)'

# Amazon Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/bashrc.post.bash" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/bashrc.post.bash"
