# ls aliases
alias ll='ls -l'
alias la='ls -A'
alias lla='ls -lA'
alias l='ls -CF'
alias sl='ls'

alias hs='homesick'

if command -v yq &>/dev/null; then
  alias jy='yq --yaml-output .'
fi

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

alias vf='vim $(fzf)'

#Unix-only
alias sshx='ssh -X'
alias less='less -R'
alias cj='cd ..'

# Completion-aware aliases
complete-alias tf terraform
complete-alias kc kubectl
complete-alias dk docker
#NOTE: Shadows GNU calculator "dc"
complete-alias dc docker-compose

function vimnote {
  #TODO: Tab completion
  #TODO: Should this update the timestamp in place?
  local title="$1"
  local notedir="${HOME}/notes"
  #find -regex can't handle this pattern
  local note="$(ls -St "${notedir}" | grep -P "${title}(\.md)?$" | head -n 1)"
  if [[ -f "${notedir}/${note}" ]]; then
    vim "${notedir}/${note}"
  elif [[ -n "${note}" ]]; then
    echo "Found multiple matches:"
    echo "${note}"
    return 1
  else
    vim "${notedir}/$(date +%Y%m%d)-${title}"
  fi
}
