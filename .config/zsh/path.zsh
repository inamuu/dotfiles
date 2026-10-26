### PATHを追加
# 後に書いたものほど PATH の先頭に来る
typeset -U path PATH
export PATH=/opt/homebrew/bin:/opt/homebrew/sbin:$PATH
export PATH=/opt/homebrew/opt/mysql-client@8.4/bin:$PATH
export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH=$HOME/ghq/github.com/inamuu/tools:$PATH
export PATH=$HOME/.local/bin:$PATH
