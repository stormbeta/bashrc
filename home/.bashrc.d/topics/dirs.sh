#!/usr/bin/env bash

# Replicate some of zsh's dir/cd features
alias cd=pushd

function d {
  if [[ $# -eq 0 ]]; then
    \cd "$(dirs -l -v | fzf --no-sort | sed -E "s/^ [0-9]+  //")"
  else
    \cd "$(dirs -l -v | fzf --no-sort -q "$@" -1 | sed -E "s/^ [0-9]+  //")"
  fi
}

function dirs-reset {
  # TODO: Make this order-preserving - very difficult to do in bash though
  local pruned_stack=($(dirs -p -l | sort | uniq))
  dirs -c
  for item in "$(pruned_stack)"; do
    pushd -n "$item"
  done
}
