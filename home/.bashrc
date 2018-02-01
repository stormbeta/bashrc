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

  local platform_config="${HOME}/.bashrc.d/platform/${PLATFORM}.sh"
  if [[ -f "${platform_config}" ]]; then
    source "${platform_config}"
  fi
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

set-if-exists EDITOR "$(command -v vim)" \
  || set-if-exists EDITOR "$(command -v vi)" \
  || set-if-exists EDITOR "$(command -v nano)" \
  || echo "WARNING: No editor found!"

bind 'set show-all-if-ambiguous on'

#Promptline
source ~/.shell_prompt.sh

set-if-exists ANDROID_HOME "${HOME}/Library/Android/sdk"
set-if-exists ANDROID_HOME "${HOME}/.android-sdk"
add-path-if-exists "${ANDROID_HOME}/platform-tools"

#export RUST_SRC_PATH="/Users/jason.miller/git/hub/rust/src"

#eval "$(pyenv init -)"
#eval "$(pyenv virtualenv-init -)"

#export NVM_DIR="/Users/jason.miller/.nvm"
#[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

#Go setup
set-if-exists GOPATH "${HOME}/go"
if [[ -n "${GOPATH}" ]]; then
  add-path-if-exists "${GOPATH}/bin"
fi

#Travis setup
source-if-exists "${HOME}/.travis/travis.sh"

#Google Cloud SDK setup
set-if-exists GOOGLE_CLOUD_HOME "${HOME}/Downloads/google-cloud-sdk"
source-if-exists "${GOOGLE_CLOUD_HOME}/path.bash.inc"
source-if-exists "${GOOGLE_CLOUD_HOME}/completion.bash.inc"
