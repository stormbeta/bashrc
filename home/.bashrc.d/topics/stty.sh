# Use ^X instead of ^S to stop control flow so I can reclaim ^S for forward
# common history search, and to allow using ^S as save in terminal editors
if stty --help &> /dev/null; then
  ##GNU/Linux version
  stty -F /dev/tty -ixon
  stty -F /dev/tty stop ^X
else
  #BSD version (e.g. OSX)
  stty -f /dev/tty -ixon
  stty -f /dev/tty stop ^X
fi
