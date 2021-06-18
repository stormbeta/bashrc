#!/usr/bin/env bash

# Tell kubectl to automatically load from ~/.kube/config.d (if they exist)
function reload-kubeconfigs {
  export KUBECONFIG="$(\
    (find "${HOME}/.kube/config.d" -type f 2>/dev/null || true) \
    | jq -R . \
    | jq -rs '[env.HOME + "/.kube/config"] + (. // empty) | join(":")' \
  )"
}
reload-kubeconfigs

# TODO: Unused?
function k8sh {
  kubectl run -i --tty "$USER-shell-$RANDOM" --image="$1" --restart=Never -- sh
}

complete-alias kl kubectl --context=docker-for-desktop
complete-alias kc kubectl
complete-alias mk minikube
complete-alias kx kubectx
#complete-alias kcl kubectl logs -f
