# Kubernetes stuff

function k8sh {
  kubectl run -i --tty "$USER-shell-$RANDOM" --image="$1" --restart=Never -- sh
}
