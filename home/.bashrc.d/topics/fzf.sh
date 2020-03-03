# fuzzy-finder + fasd utils

# cdp
# Jump to any directory you've previously cd'd into based on fuzzy matching as-you-type,
# prioritizes by recency and frequency of access. Extremely useful
# to jump between projects and directories quickly, think of it as the turbo
# version of zsh's `d` command
# Bonus: displays current git branch (if any) of target dir at bottom of screen

# vf / v
# Open file in vim via fuzzy-matching. `v` is global, `vf` is local directory tree only
# Ensures that actual open command is recorded in shell history
# Bonus: Displays preview of file contents at top of screen as-you-type

# cf
# Jump to directory in local tree via fuzzy matching

# NOTE: these methods should all follow the same basic pattern:
# 1. If the user aborts from fzf, the function should return non-zero immediately
# 2. If the result would normally be ran as an interactive command, make sure it's added to the shell history as if ran the normal way
# 3. If passed an argument, it should be used as the query to fzf, and fzf should auto-select it if it's the only match

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
    # Fuzzy match from shell history and execute it
    function hst {
      local query
      [[ $# -gt 0 ]] && query="--query=$1 --select-1"
      # NOTE: bash-specific
      local result
      result="$(history | fzf --tac --tiebreak=index $query | sed -E 's/^\s+[0-9]+ +//g')"
      [[ -n "$result" ]] || return 1
      echo -e "\033[A\033[F"
      echo "$result"
      history -r && history -s "$result"
      eval $result
    }

    # fuzzy cd to subdirectories
    function cf {
      local query
      [[ $# -gt 0 ]] && query="--query=$1 --select-1"
      local result
      result="$(find . -type d | fzf $query)"
      [[ -n "$result" ]] || return 1
      fasd_cd -d "$(realpath "$result")"
    }

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
      history -r && history -s vim "$result"
      vim "$result"
    }
  else
    _log-warn "fasd not found, 'v' fzf shortcut disabled"
  fi
else
  _log-warn "fzf not found, skipping rf/v shortcuts"
fi

