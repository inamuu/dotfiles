#
# Defines environment variables.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ "$SHLVL" -eq 1 && ! -o LOGIN && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi
if [[ -s "$HOME/.cargo" ]];then
  . "$HOME/.cargo/env"
fi

### XDG base dirs
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_STATE_HOME="${HOME}/.local/state"

if [[ -z "${XDG_RUNTIME_DIR:-}" ]]; then
  if [[ -d "/run/user/$UID" ]]; then
    export XDG_RUNTIME_DIR="/run/user/$UID"
  else
    export XDG_RUNTIME_DIR="${XDG_STATE_HOME}/runtime"
  fi
fi


