# ~/.bashrc: executed by bash(1) for non-login shells.  If not running
# interactively, don't do anything
[ -z "${PS1}" ] && return

export HOMESICK="${HOME}/.homesick/repos"

if [[ ${OS} =~ Windows ]]; then
  uname_flag='-o'
else
  uname_flag='-s'
fi

export PLATFORM=$(uname ${uname_flag} | tr "[:upper:]" "[:lower:]")

# Use custom colors for the ant console output
export ANT_OPTS="-Dant.logger.defaults=${HOME}/.ant_settings"

if [[ "${PLATFORM}" == "cygwin" ]]; then
  hostname="${COMPUTERNAME}.${USERDNSDOMAIN}"
else
  hostname=$(hostname -f)
fi

# Change git author information if I am at work.
if [[ ${hostname} =~ .+\.(ecovate|readytalk)\.com ]]; then
  export GIT_AUTHOR_EMAIL="douglas.borg@readytalk.com"
  export GIT_COMMITTER_EMAIL=${GIT_AUTHOR_EMAIL}
fi

# don't put duplicate lines in the history. See bash(1) for more options
HISTCONTROL=ignoreboth

# Use ^X instead of ^S to stop control flow so I can reclaim ^S for forward
# common history search
stty -ixon
stty stop ^X

# Some handy shell options
shell_options="checkwinsize histappend extglob cdspell dirspell globstar autocd"
if ! shopt -qs ${shell_options}; then
  echo "Warning! You are running an older verison of bash:"
  bash --version
fi

# Source my functions and start setting up my PATH
source ~/.bash_functions
pathmunge ~/bin
pathmunge ~/ReadyTalk/deploy

# Source platform dependent stuff first to help with paths, etc.
source ~/.bash_${PLATFORM}
source ~/.bash_aliases
source ~/.bash_prompt

# Set up ruby with rbenv like all the cool kids.
if [[ -d ${HOME}/.rbenv/bin  ]]; then
  pathmunge ${HOME}/.rbenv/bin
  eval "$(rbenv init -)"
fi

# Keep my .ssh stuff private.
chmod 700 ~/.homesick/repos/bashrc/home/.ssh

