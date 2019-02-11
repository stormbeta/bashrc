#!/usr/bin/env bash
# Kubernetes stuff

function kubectl-mfa {
  if [[ -n "$(find "${HOME}/.aws/credentials" -mmin +2160)" ]]; then
    ~/bin/aws-mfa-gen
  fi
  kubectl "$@"
}

# Merge kubeconfigs from ~/.kube/config.d automatically so that we can keep clusters separate

function reload-kubeconfigs {
  # Combine kubeconfigs into ':'-delimited list as KUBECONFIG, which will be auto-merged by kubectl
  local default="${HOME}/.kube/config"
  local config_dir="${HOME}/.kube/config.d"
  local config_paths=""
  [[ ! -d "$config_dir" ]] && mkdir -p "$config_dir"
  function __join { local IFS="$1"; shift; echo "$*"; }
  if [[ -n "$(ls "$config_dir")" ]]; then
    local configs=( "${config_dir}/"* )
    config_paths="$(__join : "${configs[@]}")"
  fi
  if [[ -f "$default" ]]; then
    config_paths="${default}:${config_paths}"
  fi
  export KUBECONFIG="$config_paths"
}

reload-kubeconfigs

function k8sh {
  kubectl run -i --tty "$USER-shell-$RANDOM" --image="$1" --restart=Never -- sh
}
