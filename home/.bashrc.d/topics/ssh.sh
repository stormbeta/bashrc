__profile "${BASH_SOURCE[0]}"

if [[ -n "$HOMESHICK" ]] && [[ -d "${HOMESHICK}/bashrc/home/.ssh" ]]; then
  chmod 700 "${HOMESHICK}/bashrc/home/.ssh"
fi
