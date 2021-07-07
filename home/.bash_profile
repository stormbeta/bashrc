# Under macOS, this is executed for all login shells, but bashrc only for interactive
# So try to keep anything in here relatively minimal
# TODO: Maybe add basic aliases here so they can be more easily used in scripts/snippets?
if [[ -z "$BASH_PROFILE_SOURCED" ]]; then
  BASH_PROFILE_SOURCED=1

  export LANG=en_US.UTF-8

  # Base utilities used by other config
  source "${HOME}/.bashrc.d/path-manip.sh"
  source "${HOME}/.bashrc.d/utils.sh"

  path-prepend /usr/local/bin
  path-prepend "${HOME}/bin"

  set-if-exists EDITOR "$(command -v nvim)" \
    || set-if-exists EDITOR "$(command -v vim)"
  export VISUAL="$EDITOR"

  # Python 2.7 is EOL and needs to die
  alias python=python3
  alias pip=pip3

  # NOTE: will be skipped on non-interactive shells
  source "${HOME}/.bashrc"
fi
