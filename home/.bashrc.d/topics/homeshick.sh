export HOMESICK="${HOME}/.homesick/repos"
export HOMESHICK="${HOMESICK}/homeshick"

# Use homeshick to manage my dotfiles repos.
source "${HOMESHICK}/homeshick.sh"

# My homesick repos
# @PERSONALIZE@
export HOMESICK_REPOS="dougborg/bashrc \
                       dougborg/vimrc"

# Shared dirs we should create first so homeshick repos don't mangle eachoter:
# @PERSONALIZE@
export HOMESICK_MKDIRS="${HOME}/.ssh \
                        ${HOME}/.vim \
                        ${HOME}/bin"

:<<WIP
export HOMESICK_CASTLES=$(homeshick list | tr -s ' ' | cut -d ' ' -f 2)

# Create aliases for quickly editing castles.
for castle in ${HOMESICK_CASTLES}; do
  eval "function subl-${castle} {
          subl ${HOMESICK}/${castle}
        }"
  
  eval "function vim-${castle} { 
          vim ${HOMESICK}/${castle}
        }"
done
unset castle
WIP

# Create homesick alias in case I end up typing that instead.
alias homesick=homeshick
source "${HOMESHICK}/completions/homeshick-completion.bash"
make-completion-wrapper _homeshick_complete _homesick_alias homesick 
complete -F _homesick_alias homesick
