if [[ "$SHELL_NAME" == "bash" ]]; then
  case ${PLATFORM} in
    darwin)
      # Set up bash completion on OSX with brew
      source "$(brew --prefix)/etc/bash_completion"
      source-if-exists /usr/local/opt/docker/etc/bash_completion.d/docker
      ;;
    *)
      # Completion is critical; this needs to be set up before the aliases file
      if [[ -f /etc/bash_completion ]] && ! shopt -oq posix; then
        source /etc/bash_completion
      fi
      ;;
  esac
fi

if command -v minikube &>/dev/null; then
  source <(minikube completion "$SHELL_NAME")
fi

if command -v helm &>/dev/null; then
  source <(helm completion "$SHELL_NAME" &>/dev/null)
fi

if command -v kubectl &>/dev/null; then
  source <(kubectl completion "$SHELL_NAME")
fi

#AWS CLI
if command -v aws_completer &>/dev/null; then
  complete -C "$(command -v aws_completer)" aws
fi
