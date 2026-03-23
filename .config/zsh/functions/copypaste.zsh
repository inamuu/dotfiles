
copypaste () {
  pbpaste | gsed -e '/Refreshing state/d' -e '/Creating.../d' -e '/Reading/d' -e '/Read complete/d' -e '/─────────/d' -e '/.*🎸.*inamuu.*/d' | pbcopy
}

zle -N copypaste
bindkey '^X' copypaste

