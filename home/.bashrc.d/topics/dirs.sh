#!/usr/bin/env bash

if command -v fasd &>/dev/null && command -v fzf &>/dev/null; then
  function cdp {
    #fasd_cd -d "$(fasd -d | fzf --tiebreak=index --tac | grep -Eo '/.*$')"
    fasd_cd -d "$(fasd -d | fzf --tiebreak=index --tac --preview-window=bottom:1 --preview='(cd "$(echo {} | grep -Eo "/.*$")" && cat ./$(git rev-parse --show-cdup)/.git/HEAD)' | grep -Eo '/.*$')"
  }
else
  _log-warn "fasd or fzf not found, cdp shortcut disabled"
fi
