# Avoid duplicate entries
__profile "${BASH_SOURCE[0]}"

HISTCONTROL="erasedups:ignoreboth"

# Disable bash history size limits (in combination with histappend)
export HISTSIZE=
export HISTFILESIZE=

# Auto-append new commands to the history, then reload to sync
export PROMPT_COMMAND="history -a; ${PROMPT_COMMAND}"

# Some handy shell options
shell_options="\
  checkhash \
  checkwinsize \
  histappend \
  extglob \
  cdspell \
  dirspell \
  globstar \
  autocd \
"

# This cannot be set via shopt, not sure why
#set -o noclobber

if ! shopt -qs ${shell_options}; then
  echo "
Warning! Not all shell options were set.
You are probably running an older verison of bash:
$( bash --version )

The following shell options are set:
$( shopt -s )
"
fi

# Bash 4.1+ only
bind 'set skip-completed-text on' &> /dev/null
bind 'set colored-completion-prefix on' &> /dev/null

# Bash 4.3+ only
bind 'set colored-stats on' &> /dev/null

# Show all tab completion results if multiple matches
bind 'set show-all-if-ambiguous on'

# Treat hyphens and underscores as equivalent
bind "set completion-map-case on"

# Automatically trim long paths in the prompt (requires Bash 4.x)
export PROMPT_DIRTRIM=2
