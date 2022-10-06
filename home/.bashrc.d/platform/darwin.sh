# macOS-specific bash/dotfile config
__profile "${BASH_SOURCE[0]}"

# Stuff for brew.
# M1 macOS uses different prefix
# Using env var instead of `brew --prefix` as the latter fails slowly if package isn't installed
if [[ "$(sysctl -n machdep.cpu.brand_string)" =~ "M1" ]]; then
  path-prepend /opt/homebrew/bin
fi
BREW_PREFIX="$(brew --prefix)"
path-prepend "${BREW_PREFIX}/bin"

# Use GNU coreutils if installed instead of BSD versions that come with OSX
add-path-if-exists "${BREW_PREFIX}/opt/coreutils/libexec/gnubin"
add-path-if-exists "${BREW_PREFIX}/opt/coreutils/libexec/gnuman" MANPATH
add-path-if-exists "${BREW_PREFIX}/opt/gnu-sed/libexec/gnubin"
add-path-if-exists "${BREW_PREFIX}/opt/grep/libexec/gnubin"
add-path-if-exists "${BREW_PREFIX}/opt/findutils/libexec/gnubin"

add-path-if-exists /Applications/KeePassXC.app/Contents/MacOS
source-if-exists "${HOME}/.iterm2_shell_integration.bash"

# brew-installed QT5 utils e.g. qmake
add-path-if-exists "${BREW_PREFIX}/opt/qt@5/bin"
path-append "${BREW_PREFIX}/sbin"
# TODO: is brew_installed still useful?
brew_installed=${HOME}/.brew_installed

# TODO: Is this still needed
# path-prepend /usr/local/Frameworks/Python.framework/Versions/Current/bin

# Set GOROOT for brew-installed go if present
command -v go >/dev/null && export GOROOT="${BREW_PREFIX}/opt/go/libexec"

function emptytrash {
  # Empty the Trash on all mounted volumes and the main HDD
  # Also, clear Apple’s System Logs to improve shell startup speed
  sudo rm -rfv /Volumes/*/.Trashes
  sudo rm -rfv ~/.Trash
  sudo rm -rfv /private/var/log/asl/*.asl
}

#Attach to remote shell via iTerm2 tmux integration
function ssh-tmux {
  local jump_host="${1:-jm}"
  shift 1
  ssh -tt $jump_host -C 'tmux -CC attach' $@
}

# Recursively delete `.DS_Store` files
# TODO: Is this even still an issue on modern macOS now?
alias dsclean="find . -type f -name '*.DS_Store' -ls -delete"

# Use linux-style colors for ls
export CLICOLOR=1
export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd

# Workaround for macOS Sierra+ ssh keychain problems
# '/Users/USER/.ssh/...' should be in output if it's actually loaded
if ssh-add -l 2>/dev/null | grep -vq Users; then
  # Use absolute path in case GNU version is installed with brew
  # HACK: at some point after Catalina, macOS broke ssh-add and required Apple-specific flags
  if [[ "$OSTYPE" =~ 'darwin2' ]]; then
    /usr/bin/ssh-add --use-apple-keychain &>/dev/null
  else
    /usr/bin/ssh-add -A &>/dev/null
  fi
fi

# Handy shortcut for setting up socks proxy
# alias socks='sudo networksetup -setsocksfirewallproxystate'

command -v brew &> /dev/null && brew_prefix=$( brew --prefix )
# GRC colorizes nifty unix tools all over the place
# TODO: Not sure this is working properly anymore?
if command -v grc &>/dev/null && [[ -n "${BREW_PREFIX}" ]]; then
  case "$SHELL_NAME" in
    zsh)
      source ${BREW_PREFIX}/etc/grc.zsh
      ;;
    *)
      source ${BREW_PREFIX}/etc/grc.sh
      ;;
  esac
fi

# Suspend all system activity and sleep - not the same as normal sleep
alias standby='/System/Library/CoreServices/Menu\ Extras/user.menu/Contents/Resources/CGSession -suspend'

# Enable git shell features for OSX (requires Xcode)
# TODO: Pretty sure this is deprecated for those of us installing git via brew
#darwin_git='/Applications/Xcode.app/Contents/Developer/usr/share/git-core/'
#[[ -f "${darwin_git}/git-completion.bash" ]] && . "${darwin_git}/git-completion.bash"
#[[ -f "${darwin_git}/git-prompt.sh" ]] && . "${darwin_git}/git-prompt.sh"

# Default to brew-installed java
function setjava {
  local javaVer="$1"
  export JAVA_HOME="$(ls -d "${BREW_PREFIX}/opt/openjdk@${javaVer}" | head -n1)"
}
setjava 11

set-if-exists GROOVY_HOME "${BREW_PREFIX}/opt/groovy/libexec"
source-if-exists "${BREW_PREFIX}/opt/nvm/nvm.sh"

function idea {
  local pth="${1:-.}"
  shift 1
  open -a IntelliJ\ IDEA "$pth" "$@"
}

function charm {
  local pth="${1:-.}"
  shift 1
  open -a PyCharm "$pth" "$@"
}

function mine {
  local pth="${1:-.}"
  shift 1
  open -a RubyMine "$pth" "$@"
}

# Colemak aliases
# Credit: https://stackoverflow.com/questions/21597804/determine-os-x-keyboard-layout-input-source-in-the-terminal-a-script
#export KEYBOARD_LAYOUT="$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist  AppleSelectedInputSources |  egrep -w 'KeyboardLayout Name' | gsed -E 's/^.+ = \"?([^\"]+)\"?;$/\1/')"
#if [[ "${KEYBOARD_LAYOUT}" == 'Colemak' ]]; then
  #alias cs=cd
#fi

# Open file in default web browser
function web {
  local handlers="${HOME}/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist"
  local browser="$(plutil -convert json "$handlers" -o - | \
    jq -r '.LSHandlers[] | select(.LSHandlerURLScheme == "https") | .LSHandlerRoleAll | {"org.mozilla.firefox": "Firefox", "com.google.chrome": "Google Chrome"}[.] // "Safari"')"
  open -a "$browser" "$@"
}

add-path-if-exists "${HOME}/bin"

# Reset iTerm profile to fix colorscheme bug that crops up sometimes
function fix-iterm {
  echo -e "\033]50;SetProfile=${1:-Default}\a"
}

if [[ -z "$SSH_AUTH_SOCK" ]]; then
  if [[ "$OSTYPE" =~ 'darwin2' ]]; then
    /usr/bin/ssh-add --use-apple-keychain &>/dev/null
  else
    /usr/bin/ssh-add -K &>/dev/null
  fi
else
  echo "SSH agent using key in OSX keychain." 1>&2
fi
