# Pretty much never makes sense to run service without sudo
[[ -e /usr/sbin/service ]] && alias service='sudo service'

# make less more friendly for non-text input files, see lesspipe(1)
eval "$(SHELL=/bin/sh lesspipe)"

if [[ -e "/home/linuxbrew/.linuxbrew/bin" ]]; then
  path-prepend "/home/linuxbrew/.linuxbrew/bin"
fi

function setjava {
  local jvmpath="$(find /usr/lib/jvm -maxdepth 1 -type d -name *-$1-*)"
  export JAVA_HOME="${jvmpath}"
}

if [[ -e "$(brew --prefix)/opt/openjdk" ]]; then
  path-prepend "$(brew --prefix)/opt/openjdk/bin"
fi
set-if-exists GROOVY_HOME "$(brew --prefix)/opt/groovy/libexec"

if [[ -f /usr/share/bash-completion/completions/git ]]; then
  source /usr/share/bash-completion/completions/git
fi

#http://stackoverflow.com/a/3588480
function top_level_parent_pid {
  # Look up the parent of the given PID.
  pid=${1:-$$}
  stat=($(</proc/${pid}/stat))
  ppid=${stat[3]}

  # /sbin/init always has a PID of 1, so if you reach that, the current PID is
  # the top-level parent. Otherwise, keep looking.
  if [[ ${ppid} -eq 1 ]] ; then
    echo ${pid}
  else
    top_level_parent_pid ${ppid}
  fi
}

#tmux ssh socket stuff
function ssh-fix {
  export SSH_AUTH_SOCK="$(ls -laht --full-time /tmp/ssh-*/agent.* | head -n 1 | grep -oP '[^\s]+$')"
}

alias pbpaste='xclip -selection clipboard -o'
alias pbcopy='xclip -selection clipboard'
alias open=xdg-open
