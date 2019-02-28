# fuzzy-finder + fasd utils

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
    local query
    [[ $# -gt 0 ]] && query="--query=$1 --select-1"
    local result
    result=$(fzf --preview="cat {}" --preview-window=top:25 $query)
    [[ -n "$result" ]] || return 1
    # Ensure result is in history for up-arrow completion
    history -r && history -s vim "$result"
    vim "$result"
  }

  if command -v fasd &>/dev/null; then
    function cdp {
      local query
      [[ $# -gt 0 ]] && query="--query=$1 --select-1"
      local result
      # TODO: Might want to make this smarter so that it only matches git repos?
      result="$(fasd -dl | fzf --tiebreak=index --tac --preview-window=bottom:1 --preview='(cd {} && cat ./$(git rev-parse --show-cdup)/.git/HEAD)' $query)"
      [[ -n "$result" ]] || return 1
      fasd_cd -d "$result"
    }

    function v {
      local query
      [[ $# -gt 0 ]] && query="--query=$1 --select-1"
      local result
      result="$(fasd -fl | fzf --tiebreak=index --tac --preview='cat {}' --preview-window=up:25 $query)"
      [[ -n "$result" ]] || return 1
      # Ensure result is in history for up-arrow completion
      history -r && history -s v "$result"
      vim "$result"
    }
  else
    _log-warn "fasd not found, 'v' fzf shortcut disabled"
  fi
else
  _log-warn "fzf not found, skipping rf/v shortcuts"
fi

