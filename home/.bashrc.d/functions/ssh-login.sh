function ssh_clean {
  local ssh_dir="${HOME}/.ssh"

  local known_hosts=${ssh_dir}/known_hosts
  local known_hosts_tmp=${ssh_dir}/known_hosts_tmp

  cat /dev/null > ${known_hosts_tmp}

  while read host line; do
    if [[ ${host} != "localhost" ]]; then
      echo ${host} ${line} >> ${known_hosts_tmp}
    fi
  done < ${known_hosts}

  mv ${known_hosts_tmp} ${known_hosts}

  chmod 600 ${known_hosts}
}

function start_agent {
# Initialize new agent and add authentication
  echo "Initialising new SSH agent..."

  # Start authenticating daemon
  # No authentications set up yet, just starting daemon!
  ssh-agent | head -2 > ${SSH_ENV}
  chmod 600 ${SSH_ENV}

  # Find SSH_AUTH_SOCK and SSH_AGENT_PID of the available daemon
  source ${SSH_ENV} > /dev/null

  # Add authentication to this and only this daemon
  ssh-add
}

function ssh-login {
  if [[ -f "${SSH_ENV}" ]]; then
    # Find SSH_AUTH_SOCK and SSH_AGENT_PID of the available daemon
    source ${SSH_ENV} > /dev/null

    # Check if the agent is still running
    local ierr=0
    ps ${SSH_AGENT_PID} > /dev/null || ierr=1

    if [ ${ierr} == "0" ]; then
      echo > /dev/null
    else
      # If not initialize new agent and
      # add authentication
      start_agent;
    fi
  else
    start_agent;
  fi
}
