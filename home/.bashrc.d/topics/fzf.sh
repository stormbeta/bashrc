#/usr/bin/env bash

#These are pointless if fzf doesn't exist
if command -v fzf 2>&1 > /dev/null; then
  if command -v rg &>/dev/null; then
    function rf {
      if [[ -n "$1" ]]; then
        local result="$(rg -l "$1" \
          | fzf --ansi --preview="cat {} | rg --color always $1" \
          | perl -pe 's/(^[^:]+):(\d+):.*/+\2 \1/')"
        [[ -n "$result" ]] || return 1
        vim "$result"
      else
        return 1
      fi
    }
  fi

  function vf {
    local result
    result=$(fzf --preview="cat {}" --preview-window=top:25)
    [[ -n "$result" ]] || return 1
    # Ensure result is in history for up-arrow completion
    history -r && history -s vim "$result"
    vim "$result"
  }

  if command -v fasd &>/dev/null; then
    function v {
      if [[ $# -lt 1 ]]; then
        local result
        result="$(fasd -fl | fzf --tiebreak=index --tac --preview='cat {}' --preview-window=up:25)"
        [[ -n "$result" ]] || return 1
        # Ensure result is in history for up-arrow completion
        history -r && history -s v "$result"
        vim "$result"
      else
        vim "$@"
      fi
    }
  else
    _log-warn "fasd not found, 'v' fzf shortcut disabled"
  fi
else
  _log-warn "fzf not found, skipping rf/v shortcuts"
fi

