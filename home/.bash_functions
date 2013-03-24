#!/bin/bash

function bkup {
  # Make a copy of the path to *_bkup.
  local path=${1}
  local bkup=${path}_bkup

  if [[ -e "${path}" ]]; then
    cp -a "${path}" "${bkup}"
  fi
}

function restore {
  # Restores a _bkup dir/file.
  local bkup=${1}
  local new=${1%_bkup}

  if [[ -e "${bkup}" ]]; then
    [ ! -f ${new} ] && mkdir ${new}
    diff "${bkup}" "${new}"
    cp -i "${bkup}" "${new}"
    rm -rf "${bkup}"
  fi
}

function updatehome {
  # Use homeshick to keep my dotfiles up-to-date.
  local homesick=${HOME}/.homeshick

  # Initialize homesick if needed.
  if [[ ! -x ${homesick} ]]; then
    curl -sL https://raw.github.com/andsens/homeshick/master/install.sh | bash

    bkup ${HOME}/.ssh
    bkup ${HOME}/.vim
    bkup ${HOME}/bin

    ${homesick} clone dougborg/bashrc
    ${homesick} clone dougborg/vimrc
  fi

  # Update homesick repos.
  ${homesick} pull && ${homesick} symlink
  source ${HOME}/.bashrc
  ( cd ${HOME}/.vim; make install )

  # Restore .ssh and bin, etc. if needed.
  restore ${HOME}/.ssh_bkup
  restore ${HOME}/.vim_bkup
  restore ${HOME}/bin_bkup
}

function ssh-init-home {
  local target=${1}

  ssh-copy-id ${target}
  ssh -At ${target} "$(declare -f bkup restore updatehome); updatehome; bash -l"
}

function jarls {
  jar tvf ${1}
}

function tarls {
  tar tvzf ${1} | tarcolor
}

function smart-alias {
  # Alias a command with a replacement only if both exist.
  local cmd=${1}
  shift
  local replacement=${@}

  if which ${cmd} &>/dev/null && which ${replacement%% *} &>/dev/null; then
    alias ${cmd}="${replacement}"
  fi
}

function smart_unalias {
  alias_cmd=${1}
  alias | grep -q "${alias_cmd}=" && unalias ${1};
}

function make-completion-wrapper () {
  local function_name="$2"
  local arg_count=$(($#-3))
  local comp_function_name="$1"
  shift 2
  local function="
  function $function_name {
    ((COMP_CWORD+=$arg_count))
    COMP_WORDS=( "$@" \${COMP_WORDS[@]:1} )
    "$comp_function_name"
    return 0
  }"
  eval "$function"
}

