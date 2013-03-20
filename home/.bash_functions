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

function path {
  # Print out the current path in a nice way
  ( IFS=:; printf "%s\n" ${PATH} )
}

function pathmunge {
  # Be smart about how we add new stuff to our PATH
  if ! echo ${PATH} | grep -qE "(^|:)${1}($|:)" ; then
    if [[ "${2}" == "after" ]] ; then
      PATH=${PATH}:${1}
    else
      PATH=${1}:${PATH}
    fi
  fi
}

function gcd {
  if [[ $(which git &> /dev/null) ]]; then
    STATUS=$(git status 2>/dev/null)
    if [[ -z ${STATUS} ]]; then
      return
    fi
    TARGET="./$(command git rev-parse --show-cdup)$1"
    cd ${TARGET}
  fi
}

function _git_cd {
  if $(which git &> /dev/null); then
    STATUS=$(git status 2>/dev/null)
    if [[ -z ${STATUS} ]]; then
      return
    fi
    TARGET="./$(command git rev-parse --show-cdup)"
    if [[ -d $TARGET ]]; then
      TARGET="$TARGET/"
    fi
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}$2"
    opts=$(cd $TARGET; compgen -d -o dirnames -S / -X '@(*/.git|*/.git/|.git|.git/)' $2)
    if [[ ${cur} == * ]]; then
      COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
      return 0
    fi
  fi
}

complete -o nospace -F _git_cd gcd
