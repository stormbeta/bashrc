#/usr/bin/env bash

#These are pointless if fzf doesn't exist
if command -v fzf 2>&1 > /dev/null; then
  #LastPass fuzzy selection
  function lps {
    lpass show --password --clip "$(lpass ls --long | fzf | grep -Po '(?<=id: )\d+')"
  }
fi

