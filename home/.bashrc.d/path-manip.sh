#!/usr/bin/env bash
# Utility functions for manipulating PATH vars
# Should be compatible with both bash and zsh
# NOTE: _path is used because zsh is dumb and shadows `path` with some incompatible nonsense

# path-remove directory [PATH]
function path-remove {
  local _path="$1"
  local pathVar="${2:-PATH}"
  local currPath
  if [[ -n "$BASH_VERSION" ]]; then
    currPath="${!pathVar}"
  else
    # zsh version
    currPath="${(P)pathVar}"
  fi
  local newPath="$(echo -n "$currPath" | tr ':' '\n' | grep -vxF "$_path" | tr '\n' ':' | sed 's/:$//')"
  export "$pathVar"="$newPath"
}

# Add or update directory to beginning of path
# path-prepend directory [PATH]
function path-prepend {
  local _path="$1"
  local pathVar="${2:-PATH}"
  path-remove "$_path" "$pathVar"
  local cleanPath
  if [[ -n "$BASH_VERSION" ]]; then
    cleanPath="${!pathVar}"
  else
    # zsh version
    cleanPath="${(P)pathVar}"
  fi
  export "$pathVar"="${_path}:${cleanPath}"
}

# Add or update directory to end of path
# path-append directory [PATH]
function path-append {
  local _path="$1"
  local pathVar="${2:-PATH}"
  path-remove "$_path" "$pathVar"
  local cleanPath
  if [[ -n "$BASH_VERSION" ]]; then
    cleanPath="${!pathVar}"
  else
    # zsh version
    cleanPath="${(P)pathVar}"
  fi
  export "$pathVar"="${cleanPath}:${_path}"
}

# set-if-exists VAR PATH
set-if-exists() {
  [[ -e "$2" ]] && export "$1"="$2"
}

add-path-if-exists() {
  local _path="$1"
  shift 1
  [[ -e "$_path" ]] && path-prepend "$_path" "$@"
}

source-if-exists() {
  [[ -s "$1" ]] && source "$1"
}

alias-if-exists() {
  local _alias="$1"
  shift 1
  command -v "$1" &>/dev/null && alias "$_alias"="$*"
}

# Usage: if command-exists '...'; then
command-exists() {
  command -v "$1" &>/dev/null
}
