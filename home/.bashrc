# ${HOME}/.bashrc: executed by bash(1) for non-login shells.  If not running
# interactively, don't do anything
[ -z "${PS1}" ] && export TERM='xterm' && return

#Enabled italics if supported
#TODO: Find a better way to support this that doesn't break remote terminals
export TERM='xterm-256color-italic'
(tput -T xterm-256color-italic rev &> /dev/null)
[[ $? -eq 3 ]] && export TERM='xterm-256color'

export SHELL_NAME
if [[ -n "$BASH_VERSION" ]]; then
  SHELL_NAME=bash
elif [[ -n "$ZSH_VERSION" ]]; then
  SHELL_NAME=zsh
else
  echo "Unknown shell - this is unsupported and will likely break!" 1>&2
fi

function source_platform {
  if [[ ${OS} =~ Windows ]]; then
    uname_flag='-o'
  else
    uname_flag='-s'
  fi

  export PLATFORM=$(uname ${uname_flag} | tr "[:upper:]" "[:lower:]")

  local platform_config="${HOME}/.bashrc.d/platform/${PLATFORM}.sh"
  if [[ -f "${platform_config}" ]]; then
    source "${platform_config}"
  fi
}

function sourced {
  local dir="${HOME}/.bashrc.d/$1"
  if [[ -d "$dir" ]]; then
    for script in "$dir"/*.sh; do
      source "$script"
    done
  fi
}

# Base utilities used by other config
source "${HOME}/.bashrc.d/path-manip.sh"
source "${HOME}/.bashrc.d/utils.sh"

source_platform
# tab completion
sourced completion

sourced topics

path-prepend /usr/local/bin
path-prepend "${HOME}/bin"

# FASD support
command -v fasd &>/dev/null && eval "$(fasd --init auto)"

set-if-exists EDITOR "$(command -v vim)" \
  || set-if-exists EDITOR "$(command -v vi)" \
  || set-if-exists EDITOR "$(command -v nano)" \
  || echo "WARNING: No editor found!"

#Promptline
source "${HOME}/.bashrc.d/prompt.sh"

#export RUST_SRC_PATH="/Users/jason.miller/git/hub/rust/src"

#eval "$(pyenv init -)"
#eval "$(pyenv virtualenv-init -)"

#Travis setup
source-if-exists "${HOME}/.travis/travis.sh"

# Workaround for some machine-specific variables
if [[ -f "${HOME}/backup/env" ]]; then
  source "${HOME}/backup/env"
fi

# Tillerless helm plugin defaults to using Secret storage for some reason
export HELM_TILLER_STORAGE=configmap
alias vault=/usr/local/bin/vault-wrapper
