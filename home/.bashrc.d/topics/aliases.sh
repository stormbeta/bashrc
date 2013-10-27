#!/bin/bash

# ls aliases
alias ll='ls -l'
alias la='ls -A'
alias lla='ls -lA'
alias l='ls -CF'

alias c='clear'

# Use ^X instead of ^S to stop control flow so I can reclaim ^S for forward
# common history search
stty -ixon
stty stop ^X

# vim: set ft=sh ts=2 sw=2 tw=0 :
