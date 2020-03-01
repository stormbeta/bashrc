#Homebrew settings
brew_installed=${HOME}/.brew_installed

# --------
# Snippets for manual use - TODO: put these elsewhere

# Create NFS-enabled docker-machine
# docker-machine create --driver vmwarefusion --vmwarefusion-memory-size 4096 --vmwarefusion-cpu-count 4 --vmwarefusion-no-share --vmwarefusion-disk-size 30000 default
# docker-machine-nfs default --shared-folder=$HOME


# --------

# Use GNU userland.
path-prepend /usr/local/opt/coreutils/libexec/gnubin
path-prepend /usr/local/opt/coreutils/libexec/gnuman MANPATH
path-prepend /usr/local/opt/gnu-sed/libexec/gnubin
path-prepend /usr/local/opt/grep/libexec/gnubin

# Stuff for brew.
path-prepend /usr/local/bin
path-append /usr/local/sbin

# Set GOROOT for brew-installed go if present
command -v go >/dev/null && export GOROOT='/usr/local/opt/go/libexec'

function emptytrash {
  # Empty the Trash on all mounted volumes and the main HDD
  # Also, clear Apple’s System Logs to improve shell startup speed
  sudo rm -rfv /Volumes/*/.Trashes
  sudo rm -rfv ~/.Trash
  sudo rm -rfv /private/var/log/asl/*.asl
}

#Attach to remote shell via iTerm2 tmux integration
function ssh-osx-tmux {
  local jump_host="${1:-jm}"
  shift 1
  ssh -tt $jump_host -C 'tmux -CC attach' $@
}

# Recursively delete `.DS_Store` files
# TODO: Is this even still an issue on modern macOS now?
alias dsclean="find . -type f -name '*.DS_Store' -ls -delete"

# Use GNU coreutils if installed instead of BSD versions that come with OSX
if [[ -f "/usr/local/opt/coreutils/libexec/gnubin" ]]; then
  path-prepend "/usr/local/opt/coreutils/libexec/gnubin"
  MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
fi

# Use linux-style colors for ls
export CLICOLOR=1
export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd

# Workaround for macOS Sierra ssh keychain problems
# '/Users/USER/.ssh/...' should be in output if it's actually loaded
if ssh-add -l 2>/dev/null | grep -vq Users; then
  # Use absolute path in case GNU version is installed with brew
  /usr/bin/ssh-add -A &>/dev/null
fi

# Handy shortcut for setting up socks proxy
# alias socks='sudo networksetup -setsocksfirewallproxystate'

command -v brew &> /dev/null && brew_prefix=$( brew --prefix )
# GRC colorizes nifty unix tools all over the place
if command -v grc &>/dev/null && [[ -n "${brew_prefix}" ]]; then
  source ${brew_prefix}/etc/grc.bashrc
fi

# Suspend all system activity and sleep - not the same as normal sleep
alias standby='/System/Library/CoreServices/Menu\ Extras/user.menu/Contents/Resources/CGSession -suspend'

# Enable git shell features for OSX (requires Xcode)
# TODO: Pretty sure this is deprecated for those of us installing git via brew
#darwin_git='/Applications/Xcode.app/Contents/Developer/usr/share/git-core/'
#[[ -f "${darwin_git}/git-completion.bash" ]] && . "${darwin_git}/git-completion.bash"
#[[ -f "${darwin_git}/git-prompt.sh" ]] && . "${darwin_git}/git-prompt.sh"

# TODO: Deprecate?
#complete -A hostname 'ssh-osx-tmux'

# TODO: This no longer works well when using OpenJDK via AdoptOpenJDK
function setjava {
  local javahome="$(/usr/libexec/java_home -v $1)"
  if "${javahome}/bin/java" -version 2>&1 | grep -q OpenJDK; then
    export JAVA_HOME="$javahome"
  else
    echo "Java at '${javahome}' is not OpenJDK, refusing to set JAVA_HOME" 1>&2
    return 1
  fi
}

setjava 1.8
set-if-exists GROOVY_HOME '/usr/local/opt/groovy/libexec'

# Forcibly reload macOS bluetooth kernel module
# TODO: Probably not needed anymore, was used to workaround a bug on an old laptop
function bt-reset {
  sudo kextunload -b com.apple.iokit.BroadcomBluetoothHostControllerUSBTransport
  sleep 5
  sudo kextload -b com.apple.iokit.BroadcomBluetoothHostControllerUSBTransport
}

# Colemak aliases
# Credit: https://stackoverflow.com/questions/21597804/determine-os-x-keyboard-layout-input-source-in-the-terminal-a-script
export KEYBOARD_LAYOUT="$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist  AppleSelectedInputSources |  egrep -w 'KeyboardLayout Name' | gsed -E 's/^.+ = \"?([^\"]+)\"?;$/\1/')"
if [[ "${KEYBOARD_LAYOUT}" == 'Colemak' ]]; then
  alias cs=cd
fi
