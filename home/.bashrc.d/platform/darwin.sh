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

# Stuff for brew.
path-prepend /usr/local/bin
path-append /usr/local/sbin

# TODO: This needs to be revamped to support a work vs personal list
#       also doesn't support brew cask I think
function brew {
  # Create a wrapper for brew that keeps a list of installed brew packages up to
  # date.
  if $(which brew) ${@}; then
    case ${1} in
      install)
        cat <($(which brew) list) ${brew_installed} | \
          sort | uniq > ${brew_installed}
        ;;
      remove|rm|uninstall)
        shift
        for package in ${@}; do
          command grep -v "${package}" ${brew_installed} > temp && \
            mv temp ${brew_installed}
        done
        ;;
    esac
  fi
}

function sync-brew {
  brew install $(cat ${brew_installed})
}

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
if ssh-add -l | grep -vq Users; then
  # Use absolute path in case GNU version is installed with brew
  /usr/bin/ssh-add -A
fi

# Handy shortcut for setting up socks proxy
# alias socks='sudo networksetup -setsocksfirewallproxystate'

# Setup brew prefix.
which brew &> /dev/null && brew_prefix=$( brew --prefix )

# GRC colorizes nifty unix tools all over the place
if command -v grc &>/dev/null && [[ -n "${brew_prefix}" ]]; then
  source ${brew_prefix}/etc/grc.bashrc
fi

# Suspend all system activity and sleep - not the same as normal sleep
alias standby='/System/Library/CoreServices/Menu\ Extras/user.menu/Contents/Resources/CGSession -suspend'

# Enable git shell features for OSX (requires Xcode)
darwin_git='/Applications/Xcode.app/Contents/Developer/usr/share/git-core/'
[[ -f "${darwin_git}/git-completion.bash" ]] && . "${darwin_git}/git-completion.bash"
[[ -f "${darwin_git}/git-prompt.sh" ]] && . "${darwin_git}/git-prompt.sh"

complete -A hostname 'ssh-osx-tmux'

function setjava {
  local javahome="$(/usr/libexec/java_home -v $1)"
  if "${javahome}/bin/java" -version 2>&1 | grep -q OpenJDK; then
    export JAVA_HOME="$javahome"
  else
    echo "Java at '${javahome}' is not OpenJDK, refusing to set JAVA_HOME" 1>&2
    return 1
  fi
}

setjava 11

# TODO/stale - I think this was originally added to use an alpha build of curl with http2 support?
if path-exists '/usr/local/opt/curl/bin'; then
  export PATH="/usr/local/opt/curl/bin:${PATH}"
fi

set-if-exists GROOVY_HOME '/usr/local/opt/groovy/libexec'

# Forcibly reload macOS bluetooth kernel module
function bt-reset {
  sudo kextunload -b com.apple.iokit.BroadcomBluetoothHostControllerUSBTransport
  sleep 5
  sudo kextload -b com.apple.iokit.BroadcomBluetoothHostControllerUSBTransport
}
