# ~/.bashrc: executed by bash(1) for non-login shells.
# If not running interactively, don't do anything
[ -z "${PS1}" ] && return

# Source my functions and start setting up my PATH
source ~/.bash_functions
pathmunge ~/bin

# Source platform dependent stuff to help with paths, etc.
source ~/.bash_$(uname | tr "[:upper:]" "[:lower:]") # platform-dependent configurations

# Critical. Also, make sure this is set up before my aliases file (contains completion stuff) 
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    source /etc/bash_completion
fi

# Source other parts of my configuration
source ~/.bash_aliases
source ~/.bash_prompt
source ~/.ssh/ssh-agent-setup.sh

# Set up ruby with rbenv like all the cool kids.
[[ -d ${HOME}/.rbenv/bin  ]] && pathmunge ${HOME}/.rbenv/bin
eval "$(rbenv init -)"

# don't put duplicate lines in the history. See bash(1) for more options
# don't overwrite GNU Midnight Commander's setting of `ignorespace'.
HISTCONTROL=${HISTCONTROL}${HISTCONTROL+:}ignoredups
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoreboth

# Use ^X instead of ^S to stop control flow so I can reclaim ^S for forward common history search
stty -ixon
stty stop ^X

# Some handy shell options
shopt -s checkwinsize
shopt -s histappend
shopt -s extglob
shopt -s dirspell
shopt -s globstar
shopt -s autocd
shopt -s cdspell

# Set environment options for common utilities 
export GRADLE_OPTS="-Dorg.gradle.daemon=true"
export ANT_OPTS="-Dant.logger.defaults=${HOME}/.ant_settings"
