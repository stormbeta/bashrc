__profile "${BASH_SOURCE[0]}"

if [[ -n "$HOMESHICK" ]] && [[ -d "${HOMESHICK}/bashrc/home/.ssh" ]]; then
  chmod 700 "${HOMESHICK}/bashrc/home/.ssh"
fi

# Start ssh-agent automatically if not already running
if command -v ssh-agent &>/dev/null; then
  if ! pgrep -u "$USER" ssh-agent >/dev/null; then
      eval "$(ssh-agent -s)"
  fi
fi
