# don't put duplicate lines in the history. See bash(1) for more options
HISTCONTROL=ignoreboth

# Disable bash history size limits (in combination with histappend)
export HISTSIZE=
export HISTFILESIZE=

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

if ! shopt -qs ${shell_options}; then
  echo "
Warning! Not all shell options were set.
You are probably running an older verison of bash:
$( bash --version )

The following shell options are set:
$( shopt -s )
"
fi

#Bash 4.3+ only
bind 'set colored-stats on' &> /dev/null

# Treat hyphens and underscores as equivalent
bind "set completion-map-case on"

# Avoid duplicate entries
HISTCONTROL="erasedups:ignoreboth"

# Automatically trim long paths in the prompt (requires Bash 4.x)
export PROMPT_DIRTRIM=2

case ${PLATFORM} in
  darwin)
    # Set up bash completion on OSX with brew
    if [[ -f `brew --prefix`/etc/bash_completion ]]; then
      source `brew --prefix`/etc/bash_completion
    fi
    ;;
  *)
    # Completion is critical; this needs to be set up before the aliases file
    if [[ -f /etc/bash_completion ]] && ! shopt -oq posix; then
      source /etc/bash_completion
    fi
    ;;
esac

#LastPass CLI config
if [[ -n "$(which lpass)" ]]; then
  LPASS_AGENT_TIMEOUT=6400
fi
