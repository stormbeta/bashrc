# Under macOS, this is executed for all login shells, but bashrc only for interactive
# So try to keep anything in here relatively minimal
# TODO: Maybe add basic aliases here so they can be more easily used in scripts/snippets?
if [[ -z "$BASH_PROFILE_SOURCED" ]]; then
  BASH_PROFILE_SOURCED=1

  export LANG=en_US.UTF-8

  export LAST_TIME
  function __timestamp {
    if [[ "$OSTYPE" =~ "darwin" ]]; then
      if [[ "$(sysctl -n machdep.cpu.brand_string)" =~ "M1" ]]; then
        /opt/homebrew/opt/coreutils/libexec/gnubin/date '+%s%3N'
      else
        /usr/local/opt/coreutils/libexec/gnubin/date '+%s%3N'
      fi
    else
      date '+%s%3N'
    fi
  }
  let LAST_TIME="$(__timestamp)"
  let START_TIME="$(__timestamp)"
  # Base utilities used by other config
  source "${HOME}/.bashrc.d/path-manip.sh"
  function __profile {
    # Set this to true to enable per-file profiling to troubleshoot slow bash startup times
    local enabled=false
    if [[ "$enabled" == "false" ]]; then
      return 0
    fi
    let CURRENT_TIME="$(__timestamp)"
    if [[ -z "$CURRENT_TIME" ]]; then
      let LAST_TIME=$CURRENT_TIME
    fi
    echo "${1}: $(echo "($CURRENT_TIME - $LAST_TIME)/1000.0" | bc -l | head -c7)" 1>&2
    let LAST_TIME=$CURRENT_TIME
  }
  source "${HOME}/.bashrc.d/utils.sh"

  path-prepend "${HOME}/bin"
  path-prepend /usr/local/bin

  set-if-exists EDITOR "$(command -v nvim)" \
    || set-if-exists EDITOR "$(command -v vim)"
  export VISUAL="$EDITOR"

  # Python 2.7 is EOL and needs to die
  alias python=python3
  alias pip=pip3

  # NOTE: will be skipped on non-interactive shells
  source "${HOME}/.bashrc"
fi
