__profile "${BASH_SOURCE[0]}"
# TODO: Are these superceded / conflict with GRC auto-coloring?
if command-exists dircolors; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || \
    eval "$(dircolors -b)"

  alias ls='ls --color=auto'
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'

  #alias grep='grep --color=auto -n'
  alias fgrep='fgrep --color=auto -n'
  alias egrep='egrep --color=auto -n'
fi

# Use custom colors for the ant console output
export ANT_OPTS="-Dant.logger.defaults=${HOME}/.ant_settings"
