function fzf-ssh () {
  local selected_host=$(awk '
  tolower($1)=="host" {
    for (i=2; i<=NF; i++) {
      if ($i !~ "[*?]") {
        print $i
      }
    }
  }
  ' ~/.ssh/config ~/.ssh/**/config | sort | fzf)
  if [ -n "$selected_host" ]; then
    BUFFER="ssh -A ${selected_host}"
    zle accept-line
  fi
  zle clear-screen
}

zle -N fzf-ssh
bindkey '^S' fzf-ssh

