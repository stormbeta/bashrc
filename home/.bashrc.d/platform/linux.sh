# Pretty much never makes sense to run service without sudo
[[ -e /usr/sbin/service ]] && alias service='sudo service'

# make less more friendly for non-text input files, see lesspipe(1)
eval "$(SHELL=/bin/sh lesspipe)"

# Mix the hub subcommands in with git on linux
smart-alias git 'hub'

function setjava {
  local jvmpath="$(find /usr/lib/jvm -maxdepth 1 -type d -name *-$1-*)"
  export JAVA_HOME="${jvmpath}"
}

if [[ -f /usr/share/bash-completion/completions/git ]]; then
  source /usr/share/bash-completion/completions/git
fi

#tmux ssh socket stuff
function ssh-fix {
  export SSH_AUTH_SOCK="$(find /tmp/ssh-*/agent.*)"
}
