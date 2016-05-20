# ls aliases
alias ll='ls -l'
alias la='ls -A'
alias lla='ls -lA'
alias l='ls -CF'
alias sl='ls'

alias hs='homesick'

if [[ -n "$(which nvim)" ]]; then
  alias v='nvim'
  alias n='nvim'
else
  alias v='vim'
fi

alias c='clear'

alias ssh='TERM=xterm-256color ssh'
alias e='emacsclient -t'
alias ec='emacsclient -c'

#Unix-only
alias lpw='lpass show --password -c'

alias sshx='ssh -X'

alias tf='terraform'
