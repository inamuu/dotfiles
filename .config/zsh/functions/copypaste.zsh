
copypaste () {
  pbpaste | gsed -e '/Refreshing state/d' -e '/Creating.../d' -e '/Reading/d' -e '/Read complete/d' -e '/─────────/d' | pbcopy
}

zle -N copypaste
bindkey '^Rc' copypaste

