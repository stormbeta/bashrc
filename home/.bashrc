# ~/.bashrc: executed by bash(1) for non-login shells.
# If not running interactively, don't do anything
[ -z "${PS1}" ] && return

# Source my functions and start setting up my PATH
source ~/.bash_functions
pathmunge ~/bin

# Source platform dependent stuff to help with paths, etc.
source ~/.bash_$(uname | tr "[:upper:]" "[:lower:]")

# Source other parts of my configuration
source ~/.bash_aliases
source ~/.bash_prompt

# Set up ruby with rbenv like all the cool kids.
if [[ -d ${HOME}/.rbenv/bin  ]]; then
  pathmunge ${HOME}/.rbenv/bin
  eval "$(rbenv init -)"
fi

if [[ $(hostname -f) =~ \.+(ecovate|readytalk)\.com ]]; then
  export GIT_AUTHOR_EMAIL="douglas.borg@readytalk.com"
  export GIT_COMMITTER_EMAIL=${GIT_AUTHOR_EMAIL}
fi

# Keep my stuff private.
chmod 700 ~/.homesick/repos/bashrc/home/.ssh

# don't put duplicate lines in the history. See bash(1) for more options
HISTCONTROL=ignoreboth

# Use ^X instead of ^S to stop control flow so I can reclaim ^S for forward common history search
stty -ixon
stty stop ^X

# Some handy shell options
if ! shopt -qs checkwinsize histappend extglob cdspell dirspell globstar autocd; then
  echo "Warning! You are running an older verison of bash:"
  bash --version
fi

# Use custom colors for the ant console output
export ANT_OPTS="-Dant.logger.defaults=${HOME}/.ant_settings"
