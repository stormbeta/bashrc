__profile "${BASH_SOURCE[0]}"
export HOMESICK="${HOME}/.homesick/repos"
export HOMESHICK="${HOMESICK}/homeshick"

source "${HOMESHICK}/homeshick.sh"

# TODO: Is this used by anything still?
export HOMESICK_MKDIRS=(".ssh" ".vim" "bin")

# Create homesick alias in case I end up typing that instead.
alias homesick=homeshick
source "${HOMESHICK}/completions/homeshick-completion.bash"
make-completion-wrapper _homeshick_complete _homesick_alias homesick
complete -F _homesick_alias homesick
