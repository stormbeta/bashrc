#!/bin/bash

# Oh, THE COLORS!
if which dircolors >/dev/null 2>&1; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'

  alias grep='grep --color=auto -n'
  alias fgrep='fgrep --color=auto -n'
  alias egrep='egrep --color=auto -n'
fi

# Create aliases for color version of optional commands if they both exist
smart-alias svn 'colorsvn'
smart-alias ant 'ant -logger org.apache.tools.ant.listener.AnsiColorLogger'

# Work proxy
alias ssh-proxy='ssh -D 9000 -Nf 1900.readytalk.com 2>/dev/null'

# ls aliases
alias ll='ls -l'
alias la='ls -A'
alias lla='ls -lA'
alias l='ls -CF'

# Mix the hub subcommands in with git
smart-alias git 'hub'

# git shortcuts
alias g='git status'
alias gco='git checkout'
alias gf='git fetch'
alias gb='git branch'
alias gd='git diff'
alias gcp='git cherry-pick'

# git completion for shortcuts
complete -o default -o nospace -F _git_status g
complete -o default -o nospace -F _git_checkout gco
complete -o default -o nospace -F _git_fetch gf
complete -o default -o nospace -F _git_branch gb
complete -o default -o nospace -F _git_diff gd
complete -o default -o nospace -F _git_cherry_pick gcp
