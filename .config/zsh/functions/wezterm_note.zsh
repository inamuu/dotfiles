_wezterm_note_file() {
  local cache_root="${XDG_CACHE_HOME:-$HOME/.cache}"
  print -r -- "${cache_root}/wezterm-note/current.txt"
}

_wezterm_note_write_file() {
  local note_file note_dir

  note_file="$(_wezterm_note_file)"
  note_dir="${note_file:h}"
  mkdir -p "${note_dir}" || return 1

  if [[ -n "$1" ]]; then
    printf '%s\n' "$1" >| "${note_file}"
  else
    command rm -f "${note_file}"
  fi
}

wezterm-note() {
  export WEZTERM_NOTE_TEXT="$*"
  _wezterm_note_write_file "${WEZTERM_NOTE_TEXT}" || return 1

  if typeset -f __wezterm_set_user_var >/dev/null 2>&1; then
    __wezterm_set_user_var "WEZTERM_NOTE" "${WEZTERM_NOTE_TEXT}"
  fi
}

wezterm-note-clear() {
  unset WEZTERM_NOTE_TEXT
  _wezterm_note_write_file "" || return 1

  if typeset -f __wezterm_set_user_var >/dev/null 2>&1; then
    __wezterm_set_user_var "WEZTERM_NOTE" ""
  fi
}

wezterm-note-run() {
  local previous_note="${WEZTERM_NOTE_TEXT-}"
  local note=${1:?usage: wezterm-note-run <note> <command> [args...]}

  shift
  (( $# > 0 )) || {
    print -u2 "usage: wezterm-note-run <note> <command> [args...]"
    return 1
  }

  wezterm-note "${note}" || return $?
  "$@"
  local status=$?

  if [[ -n "${previous_note}" ]]; then
    wezterm-note "${previous_note}"
  else
    wezterm-note-clear
  fi

  return ${status}
}

alias wzn='wezterm-note'
alias wznc='wezterm-note-clear'
alias wznr='wezterm-note-run'
