# ${HOME}/.bashrc: executed by bash(1) for non-login shells.  If not running
# interactively, don't do anything
[ -z "${PS1}" ] && export TERM='xterm' && return

source "${HOME}/.bash_profile"

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
    local uname_flag='-o'
  else
    local uname_flag='-s'
  fi

  export PLATFORM="$(uname ${uname_flag} | tr "[:upper:]" "[:lower:]")"

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
sourced completion
sourced topics

# FASD support
command -v fasd &>/dev/null && eval "$(fasd --init auto)"

# TEMP function to build config
function add-dotfile {
  local rpath="$(realpath "$1" --relative-to="$HOME")"
  local castle="${HOME}/.homesick/repos/linux-desktop-rc/home"
  local dirpth="$(realpath "$(dirname "$1")" --relative-to="$HOME")"
  local fname="$(basename "$1")"
  mkdir -p "${castle}/${dirpth}"
  cp "$1" "${castle}/${dirpth}"
  (
    cd "$castle"
    git add "${dirpth}/${fname}"
  )
}

#Promptline
source "${HOME}/.bashrc.d/prompt.sh"

let CURRENT_TIME="$(date +%s%3N)"
if [[ -z "$CURRENT_TIME" ]]; then
  let LAST_TIME=$CURRENT_TIME
fi
echo "BASH STARTUP TIME: $(echo "($CURRENT_TIME - $START_TIME)/1000.0" | bc -l | head -c7)" 1>&2
