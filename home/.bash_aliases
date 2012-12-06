# Oh, THE COLORS!
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'

  alias grep='grep --color=auto -n'
  alias fgrep='fgrep --color=auto -n'
  alias egrep='egrep --color=auto -n'

	alias svn='colorsvn'
	alias ant='ant -logger org.apache.tools.ant.listener.AnsiColorLogger'
fi

# ls aliases
alias ll='ls -l'
alias la='ls -A'
alias lla='ls -lA'
alias l='ls -CF'

# Git shortcuts with completion
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
