# Set some super basic stuff
export PATH="${HOME}/bin:${PATH}"
export EDITOR="vim"
export VISUAL="${EDITOR}"
export LANG=en_US.UTF-8

source ~/.bashrc

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# Add rust binaries to PATH
if command -v rustup &>/dev/null && [[ -d "${HOME}/.cargo/bin" ]]; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi
