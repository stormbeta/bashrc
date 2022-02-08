__profile "${BASH_SOURCE[0]}"

if [[ -n "$HOMESHICK" ]] && [[ -d "${HOMESHICK}/bashrc/home/.ssh" ]]; then
  chmod 700 "${HOMESHICK}/bashrc/home/.ssh"
fi

# TODO: Should this be in platforms?

# Initialize ssh agent if needed
case ${PLATFORM} in
  darwin)
    if [[ -z "$SSH_AUTH_SOCK" ]]; then
      if [[ "$OSTYPE" =~ 'darwin2' ]]; then
        /usr/bin/ssh-add --use-apple-keychain &>/dev/null
      else
        /usr/bin/ssh-add -K &>/dev/null
      fi
    else
      echo "SSH agent using key in OSX keychain." 1>&2
    fi
    ;;
  *)
    if [[ -z ${SSH_AUTH_SOCK} ]] && [[ -e "${SSH_AUTH_SOCK}" ]]  ; then
      export SSH_ENV=${HOME}/.ssh/env-${HOSTNAME}
      export SSH_CONFIG=${HOME}/.ssh/config
      ssh-login
    else
      echo "SSH agent already active from another session or host."
    fi
    ;;
esac
