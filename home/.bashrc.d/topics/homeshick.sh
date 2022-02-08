__profile "${BASH_SOURCE[0]}"

export HOMESICK="${HOME}/.homesick/repos"
export HOMESHICK="${HOMESICK}/homeshick"

if source-if-exists "${HOMESHICK}/homeshick.sh"; then
  alias homesick=homeshick
  alias hs=homeshick
  source "${HOMESHICK}/completions/homeshick-completion.bash"
  make-completion-wrapper _homeshick_complete _homesick_alias homesick
  complete -F _homesick_alias homesick
fi
