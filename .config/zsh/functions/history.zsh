# http://mollifier.hatenablog.com/entry/20090728/p1
zshaddhistory() {
    local line=${1%%$'\n'} #コマンドライン全体から改行を除去したもの
    local cmd=${line%% *}  # １つ目のコマンド
    # 以下の条件をすべて満たすものだけをヒストリに追加する
    [[ ${#line} -ge 5
        && ${cmd} != (l|l[sal])
        && ${cmd} != (eza)
        && ${cmd} != (cd)
        && ${cmd} != (m|man)
        && ${cmd} != (r[mr])
        && ${cmd} != (terraform apply)
    ]]
}

### History
#HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
function history-all { history -E 1 }
setopt hist_ignore_dups

# 入力文字列をスペース込みのフレーズとして部分一致検索する (ex: "aws ecr")
function fzf-history-selection() {
    local tmp=${XDG_CACHE_HOME:-$HOME/.cache}/zsh/fzf-history
    mkdir -p ${tmp:h}
    fc -rl 1 \
        | awk '{$1=""; sub(/^ /, ""); print}' \
        | egrep -v "^(ls|eza)( |$)" \
        | awk '!seen[$0]++' > $tmp
    local selected=$(
        fzf --disabled --query "$LBUFFER" \
            --bind "start:reload(rg -F -i --no-line-number --color=never -- {q} $tmp || true)" \
            --bind "change:reload(rg -F -i --no-line-number --color=never -- {q} $tmp || true)"
    )
    [[ -n $selected ]] && BUFFER=$selected
    CURSOR=$#BUFFER
    zle reset-prompt
}

zle -N fzf-history-selection
bindkey '^R' fzf-history-selection
