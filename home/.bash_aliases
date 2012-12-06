#!/bin/bash

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'

  alias grep='grep --color=auto -n'
  alias fgrep='fgrep --color=auto -n'
  alias egrep='egrep --color=auto -n'
fi

# some more ls aliases
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

alias sag='sudo apt-get'
alias svn='colorsvn'

if [[ -e /usr/sbin/service ]]; then
  alias service='sudo service'
fi

alias ant='ant -logger org.apache.tools.ant.listener.AnsiColorLogger'

alias g='git status'
alias gco='git checkout'
alias gf='git fetch'
alias gb='git branch'
alias gd='git diff'
alias gcp='git cherry-pick'
alias gcd='[[ $(git rev-parse --show-cdup 2> /dev/null) =~ ".." ]] && cd $(git rev-parse --show-cdup)'

complete -o default -o nospace -F _git_status g
complete -o default -o nospace -F _git_checkout gco
complete -o default -o nospace -F _git_fetch gf
complete -o default -o nospace -F _git_branch gb
complete -o default -o nospace -F _git_diff gd
complete -o default -o nospace -F _git_cherry_pick gcp
