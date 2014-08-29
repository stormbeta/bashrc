# Change git author information if I am at work.
if [[ "${PLATFORM}" == "cygwin" ]]; then
  hostname="${COMPUTERNAME}.${USERDNSDOMAIN}"
else
  hostname=$(hostname -f)
fi

#TODO: Find a way to dynamically set this by repository, not just host/id
if [[ ${hostname} =~ .+\.(ecovate|readytalk)\.com ]] || \
   [[ `id` =~ 'READYTALK' ]]; then
  export GIT_AUTHOR_EMAIL="jason.miller@readytalk.com"
  export GIT_COMMITTER_EMAIL=${GIT_AUTHOR_EMAIL}
fi

# git shortcuts
alias g='git status'
alias gco='git checkout'
alias gf='git fetch'
alias gb='git branch'
alias gd='git diff'
alias gpf='git fetch --all && git pull -r || git pull --ff-only'
alias gfp='gpf'

# git completion for shortcuts
complete -o default -o nospace -F _git_status g
complete -o default -o nospace -F _git_checkout gco
complete -o default -o nospace -F _git_fetch gf
complete -o default -o nospace -F _git_branch gb
complete -o default -o nospace -F _git_diff gd
complete -o default -o nospace -F _git_cherry_pick gcp
