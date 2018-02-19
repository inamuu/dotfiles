# Path to Oh My Fish install.
set -q XDG_DATA_HOME
  and set -gx OMF_PATH "$XDG_DATA_HOME/omf"
  or set -gx OMF_PATH "$HOME/.local/share/omf"

# Load Oh My Fish configuration.
source $OMF_PATH/init.fish

# Theme
set fish_theme agnoster

### shell command
alias ls='ls -laG'
alias ll='ls -laG'
alias rm='rm -vi'
alias mv='mv -vi'
alias cp='cp -vi'
alias ..='cd ..'
alias vi='vim'
alias c='clear'

### tmux bug fix
alias ssh='env TERM=xterm ssh'

### git
alias g='git'
alias gs='git status'
alias gb='git branch'
alias gc='git checkout'
alias gcm='git commit'
alias gd='git diff'
alias gl='git log'
alias ga='git add'
alias gpl='git pull'
alias gps='git push -u origin'
alias gpsf='git push -f -u origin'

### bundle
alias be='bundle exec'

### hub
alias gh='cd (ghq root)/(ghq list | peco)'

### Python
#export PYENV_ROOT="$HOME/.pyenv"
#export PATH="$PYENV_ROOT/bin:$PATH"

### Ruby
#PATH=~/.rbenv/shims:"$PATH"

### docker
alias do='docker'
alias doc='docker-compose'

### Others
alias evc='envchain'
