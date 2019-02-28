# Set some super basic stuff
export PATH="${HOME}/bin:${PATH}"
export EDITOR="vim"
export VISUAL="${EDITOR}"
export LANG=en_US.UTF-8

source "${HOME}/.bashrc"

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
