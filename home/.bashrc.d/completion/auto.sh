if command -v minikube &>/dev/null; then
  eval "$(minikube completion "$SHELL_NAME")"
fi

if command -v helm &>/dev/null; then
  eval "$(helm completion "$SHELL_NAME")"
fi
