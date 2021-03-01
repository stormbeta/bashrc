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

# TODO: Unused?
function k8sh {
  kubectl run -i --tty "$USER-shell-$RANDOM" --image="$1" --restart=Never -- sh
}

# TODO: Unused?
function kg {
  "$@" -oname | fzf --ansi # | "$@" -ojson "$(</dev/stdin)" | jq .
}

# TODO: zsh support?
complete-alias kl kubectl --context=docker-for-desktop
complete-alias kc kubectl
complete-alias kcl kubectl logs -f
complete-alias kj kubectl -o json
complete-alias kd kubectl --namespace default
complete-alias mk minikube
complete-alias kx kubectx
complete-alias kxec kubectl -it exec

complete-alias kl kubectl --server=127.0.0.1:8001
complete-alias klp kubectl --server=127.0.0.1:8002
complete-alias klc kubectl --server=127.0.0.1:8003
complete-alias klt kubectl --server=127.0.0.1:8004
complete-alias klo kubectl --server=127.0.0.1:8005
complete-alias kle kubectl --server=127.0.0.1:8007
complete-alias kll kubectl --server=127.0.0.1:8008
complete-alias klow kubectl --server=127.0.0.1:8009
complete-alias kla kubectl --server=127.0.0.1:8010
