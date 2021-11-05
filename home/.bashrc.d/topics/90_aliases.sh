__profile "${BASH_SOURCE[0]}"
# ls aliases
alias ll='ls -l'
alias la='ls -A'
alias lla='ls -lA'
alias l='ls -CF'
alias sl='ls'

alias hs='homesick'

alias-if-exists jy yq --yaml-output .
alias-if-exists ping prettyping
alias-if-exists vim nvim -p
alias-if-exists n nvim -p || alias-if-exists n vim
#alias-if-exists cat bat --theme GitHub
alias bat='bat --theme GitHub'

alias ssh='TERM=xterm-256color ssh'
alias e='emacsclient -t'
alias ec='emacsclient -c'

#Unix-only
alias sshx='ssh -X'
alias less='less -R'
alias cj='cd ..'
alias cp='rsync -ah --progress'

# Completion-aware aliases
complete-alias tf terraform
complete-alias mk minikube
complete-alias kx kubectx

# Git
complete-alias gpv git commit -pv
complete-alias gco git checkout
# TODO: Figure out why this doesn't work
#complete-alias gh GIT_COMMITTER_EMAIL='stormbeta@gmail.com' GIT_AUTHOR_EMAIL='stormbeta@gmail.com' git

# Docker
complete-alias dk docker
#NOTE: Shadows GNU calculator "dc"
complete-alias dc docker-compose
complete-alias drv docker run -it --rm -v "\${PWD}:/local" -w /local
complete-alias dr docker run -it --rm -v "\${PWD}:/local"

# Typical watch alias, perserves alias expansion (ish)
alias ww='watch --color -n 1 '
alias watch='watch --color '

alias gr='gron | grep --color=auto -P'
alias rga='rg --no-ignore --no-hidden'

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
