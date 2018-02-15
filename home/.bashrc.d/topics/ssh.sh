chmod 700 ${HOMESICK}/bashrc/home/.ssh

#TODO: This doesn't work properly with tmux

# TODO: Should this be in platforms?

case ${PLATFORM} in
  darwin)
    # Setup ssh stuff.
    if [[ -z ${SSH_AUTH_SOCK} ]]; then
      ssh-add -K
    else
      echo "SSH agent using key in OSX keychain."
    fi
    if [[ -f "${HOME}/.ssh/id_rsa" ]]; then
      if ! ssh-add -l | cut -d' ' -f3 | grep '.ssh/id_rsa'; then
        ssh-add "${HOME}/.ssh/id_rsa"
      fi
    fi
    ;;
  *)
    # Setup ssh agent.
    if [[ -z ${SSH_AUTH_SOCK} ]] && [[ -e "${SSH_AUTH_SOCK}" ]]  ; then
      export SSH_ENV=${HOME}/.ssh/env-${HOSTNAME}
      export SSH_CONFIG=${HOME}/.ssh/config
      ssh-login
    else
      echo "SSH agent already active from another session or host."
    fi
    ;;
esac
