# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="yyyy/mm/dd"

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

function fzf-history-selection() {
    BUFFER=$(history | awk '{$1="";print $0}' | egrep -v "ls" | uniq -u | sed 's/^ //g' | fzf)
    CURSOR=$#BUFFER
    zle reset-prompt
}

zle -N fzf-history-selection
bindkey '^Rr' fzf-history-selection

