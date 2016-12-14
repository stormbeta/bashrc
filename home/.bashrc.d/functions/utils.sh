#!/usr/bin/env bash

function path-exists {
  local check_path="$1"
  [[ -e "$check_path" ]]
  return $?
}

set-if-exists() {
  local var_name="$1"
  local check_path="$2"
  if path-exists "${check_path}"; then
    #typeset -x doesn't work
    eval "export ${var_name}=${check_path}"
  fi
}

function add-path-if-exists {
  local check_path="$1"
  if path-exists "$check_path"; then
    path-prepend "$check_path"
  fi
}

function source-if-exists {
  local check_path="$1"
  if path-exists "$check_path"; then
    source "$check_path"
  fi
}
