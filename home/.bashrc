# ${HOME}/.bashrc: executed by bash(1) for non-login shells.  If not running
# interactively, don't do anything
[ -z "${PS1}" ] && export TERM='xterm' && return

export TERM='xterm-256color-italic'
(tput -T xterm-256color-italic rev &> /dev/null)
[[ $? -eq 3 ]] && export TERM='xterm-256color'

function source_platform {
  if [[ ${OS} =~ Windows ]]; then
    uname_flag='-o'
  else
    uname_flag='-s'
  fi

  export PLATFORM=$(uname ${uname_flag} | tr "[:upper:]" "[:lower:]")

  source ${HOME}/.bashrc.d/platform/${PLATFORM}.sh
}

function sourced {
  local dir=${HOME}/.bashrc.d/${1}

  if [[ -d ${dir} ]]; then
    while read dotd; do
      source "${dotd}"
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

export DOCKER_HOST='tcp://192.168.50.241:4244'

if [[ -n "$(which powerline-daemon)" ]]; then
  #TODO: This is extremely specific to OSX, and needs to be updated
  #It's also very slow since it uses a python daemon; look into using promptline instead
  powerline-daemon -q
  #POWERLINE_BASH_CONTINUATION=1
  #POWERLINE_BASH_SELECT=1
  . /usr/local/lib/python2.7/site-packages/powerline/bindings/bash/powerline.sh
fi
