# ${HOME}/.bashrc: executed by bash(1) for non-login shells.  If not running
# interactively, don't do anything
[ -z "${PS1}" ] && export TERM='xterm' && return

#Enabled italics if supported
#TODO: Find a better way to support this that doesn't break remote terminals
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

#TODO: Only source completion for commands found in the current environment
# Source bash completion
sourced completion

path-remove /usr/local/bin
path-prepend /usr/local/bin

bind 'set show-all-if-ambiguous on'

export GOPATH=${HOME}/go
export PATH="${PATH}:${GOPATH}/bin"

#Promptline
if [[ -z "${TMUX}" ]]; then
  source ~/.shell_prompt.sh
else
  source ~/.tmux_prompt.sh
fi
PATH="${PATH}:${HOME}/.android-sdk/platform-tools"

# added by travis gem
[ -f ${HOME}/.travis/travis.sh ] && source ${HOME}/.travis/travis.sh

if [[ -f '~/.secret/aws' ]]; then
  source '~/.secret/aws'
fi
