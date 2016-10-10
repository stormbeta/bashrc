#/usr/bin/env bash

#These are pointless if fzf doesn't exist
if command -v fzf 2>&1 > /dev/null; then
  #LastPass fuzzy selection
  function lps {
    #Ensure login state first; fzf can't handle nested interactive input
    lpass status --quiet || lpass sync
    lpass show --password --clip \
      "$(lpass ls --long | fzf | grep -Po '(?<=id: )\d+')"
  }
else
  echo '[WARN]: fzf not installed, skipping fzf-based functions and aliases' 1>&2 >> ~/.bash_warnings
fi

