#/usr/bin/env bash

#These are pointless if fzf doesn't exist
if command -v fzf 2>&1 > /dev/null; then
  #LastPass fuzzy selection
  function lps {
    #Ensure login state first; fzf can't handle nested interactive input
    lpass status --quiet || lpass sync
    local lpass_id="$(lpass ls --long | fzf --select-1 --query="$1" | grep -Po '(?<=id: )\d+')"
    lpass show --url ${lpass_id}
    lpass show --clip --password ${lpass_id}
  }

  function lpo {
    #Ensure login state first; fzf can't handle nested interactive input
    lpass status --quiet || lpass sync
    local lpass_id="$(lpass ls --long | fzf --select-1 --query="$1" | grep -Po '(?<=id: )\d+')"
    lpass show --clip --password ${lpass_id}
    if [[ "$(uname -o)" == 'Darwin' ]]; then
      local lpass_url="$(lpass show --url ${lpass_id})"
      open "${lpass_url}"
    else
      lpass show --url ${lpass_id}
    fi
  }

  function agf {
    if [[ -n "$1" ]]; then
      local result="$(ag -l "$1" \
        | fzf --ansi --preview="cat {} | ag --color $1" \
        | perl -pe 's/(^[^:]+):(\d+):.*/+\2 \1/')"
      if [[ -n "$result" ]]; then
        vim $result
      else
        return 1
      fi
    else
      return 1
    fi
  }

  function vimf {
    local result=''
    if [[ -n "$2" ]]; then
      local result="$(ag -G "$1$" --vimgrep "$1" | fzf | perl -pe 's/(^[^:]+):(\d+):.*/+\2 \1/')"
    elif [[ -n "$1" ]]; then
      result="$(ag -l -G "$1$" . | fzf)"
    else
      result="$(fzf)"
    fi

    if [[ -n "$result" ]]; then
      vim $result
    else
      return 1
    fi
  }
else
  echo '[WARN]: fzf not installed, skipping fzf-based functions and aliases' 1>&2 >> ~/.bash_warnings
fi

