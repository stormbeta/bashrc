__profile "${BASH_SOURCE[0]}"

if [[ -n "$HOMESHICK" ]] && [[ -d "${HOMESHICK}/bashrc/home/.ssh" ]]; then
  chmod 700 "${HOMESHICK}/bashrc/home/.ssh"
fi

# Restrict to desktop system, maybe use hostname instead?
if grep -q Gentoo /etc/os-release; then
  eval $(keychain --eval --quick --quiet --agents ssh)
fi

# Start ssh-agent automatically if not already running
#if ! pgrep -u "$USER" ssh-agent >/dev/null; then
  #eval "$(ssh-agent -s)"
#fi
