# ${HOME}/.bashrc: executed by bash(1) for non-login shells.  If not running
# interactively, don't do anything
[ -z "${PS1}" ] && export TERM='xterm' && return

# TODO: This doesn't appear to be needed on macOS, verify if still needed on linux
#       Was originally used to force-enable italics on terminals that wouldn't use it otherwise
#export TERM='xterm-256color-italic'
#(tput -T xterm-256color-italic rev &> /dev/null)
#[[ $? -eq 3 ]] && export TERM='xterm-256color'

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
source_platform

function sourced {
  local dir="${HOME}/.bashrc.d/$1"
  if [[ -d "$dir" ]]; then
    for script in "$dir"/*.sh; do
      source "$script"
    done
  fi
}
# tab completion
sourced completion
sourced topics

# FASD support
command -v fasd &>/dev/null && eval "$(fasd --init auto)"

#Promptline
source "${HOME}/.bashrc.d/prompt.sh"

#export RUST_SRC_PATH="/Users/jason.miller/git/hub/rust/src"
export PATH="${HOME}/android-sdk/platform-tools:${PATH}"

#eval "$(pyenv init -)"
#eval "$(pyenv virtualenv-init -)"

#Travis setup
source-if-exists "${HOME}/.travis/travis.sh"

# Workaround for some machine-specific variables
source-if-exists "${HOME}/backup/env"

source-if-exists "${HOME}/github/stormbeta/snippets/python/pyw/pyw.bashrc"

# TODO: move to macOS-specific config
source-if-exists "${HOME}/.iterm2_shell_integration.bash"
add-path-if-exists "/usr/local/opt/qt@5/bin"

add-path-if-exists "${HOME}/.rvm/bin"
source-if-exists "${HOME}/.rvm/scripts/rvm"
