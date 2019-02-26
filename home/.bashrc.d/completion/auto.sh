if command -v minikube &>/dev/null; then
  source <(minikube completion "$SHELL_NAME")
fi

if command -v helm &>/dev/null; then
  source <(helm completion "$SHELL_NAME")
fi

if command -v kubeclt &>/dev/null; then
  source <(kubectl completion "$SHELL_NAME")
fi
