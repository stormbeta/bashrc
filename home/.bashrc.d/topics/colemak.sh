#!/usr/bin/env bash

# Colemak aliases

# NOTE: MacOS only
# Credit: https://stackoverflow.com/questions/21597804/determine-os-x-keyboard-layout-input-source-in-the-terminal-a-script
export KEYBOARD_LAYOUT="$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist  AppleSelectedInputSources |  egrep -w 'KeyboardLayout Name' | gsed -E 's/^.+ = \"?([^\"]+)\"?;$/\1/')"

if [[ "${KEYBOARD_LAYOUT}" == 'Colemak' ]]; then
  alias cs=cd
fi
