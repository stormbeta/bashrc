#/usr/bin/env bash

#These are pointless if fzf doesn't exist
if command -v fzf 2>&1 > /dev/null; then
  if command -v rg &>/dev/null; then
    function rf {
      if [[ -n "$1" ]]; then
        local result="$(rg -l "$1" \
          | fzf --ansi --preview="cat {} | rg --color always $1" \
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
  fi


  if command -v fasd &>/dev/null; then
    function v {
      if [[ $# -lt 1 ]]; then
        nvim "$(fasd -f | fzf --tiebreak=index --tac --preview='cat "$(echo {} | grep -Eo "/.*$")"' --preview-window=up:25 | grep -Eo '/.*$')"
      else
        nvim "$@"
      fi
    }
  else
    _log-warn "fasd not found, 'v' fzf shortcut disabled"
  fi
else
  _log-warn "fzf not found, skipping rf/v shortcuts"
fi

