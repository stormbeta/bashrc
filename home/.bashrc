# ${HOME}/.bashrc: executed by bash(1) for non-login shells.  If not running
# interactively, don't do anything
[ -z "${PS1}" ] && return

function source_platform {
  if [[ ${OS} =~ Windows ]]; then
    uname_flag='-o'
  else
    uname_flag='-s'
  fi

  export PLATFORM=$(uname ${uname_flag} | tr "[:upper:]" "[:lower:]")

  echo "Sourcing ${PLATFORM}"
  time source ${HOME}/.bashrc.d/platform/${PLATFORM}.sh
}

function sourced {
  local dir=${HOME}/.bashrc.d/${1}

  if [[ -d ${dir} ]]; then
    while read dotd; do
      echo "Sourcing ${dotd}"
      time source "${dotd}"
    done < <(find ${dir} -name '*.sh')
    unset dotd
  fi
}

# Source my functions and start setting up my PATH
sourced functions
path-prepend ${HOME}/bin

# Source platform dependent stuff first to help with paths, etc.
source_platform

# Source the rest of the things.
sourced topics

path-remove /usr/local/bin
path-prepend /usr/local/bin

bind 'set show-all-if-ambiguous on'
