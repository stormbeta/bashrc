#Homebrew settings
brew_installed=${HOME}/.brew_installed

# Use GNU userland.
path-prepend /usr/local/opt/coreutils/libexec/gnubin
path-prepend /usr/local/opt/coreutils/libexec/gnuman MANPATH

# Stuff for brew.
path-prepend /usr/local/bin
path-append /usr/local/sbin

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

# Handy shortcut for setting up socks proxy
# alias socks='sudo networksetup -setsocksfirewallproxystate'

# Setup brew prefix.
which brew &> /dev/null && brew_prefix=$( brew --prefix )

# GRC colorizes nifty unix tools all over the place
if which grc &>/dev/null && [[ -n "${brew_prefix}" ]]; then
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
  export JAVA_HOME=`/usr/libexec/java_home -v 1.$1`
}

setjava 8

if path-exists '/usr/local/opt/curl/bin'; then
  export PATH="/usr/local/opt/curl/bin:${PATH}"
fi

set-if-exists GROOVY_HOME '/usr/local/opt/groovy/libexec'

function bt-reset {
  sudo kextunload -b com.apple.iokit.BroadcomBluetoothHostControllerUSBTransport
  sleep 5
  sudo kextload -b com.apple.iokit.BroadcomBluetoothHostControllerUSBTransport
}
