# Paths and setup for various CLI tools and utitlies

__profile "${BASH_SOURCE[0]}"

# Paths and setup for various CLI tools and utitlies

# Ruby Version Manager (load as a function)
if source-if-exists "${HOME}/.rvm/scripts/rvm"; then
  add-path-if-exists "${HOME}/.rvm/bin"
fi

# NodeJS Version Manager
if [[ -f "${HOME}/.nvm/nvm.sh" ]]; then
  export NVM_DIR="${HOME}/.nvm"
  # nvm insists on spamming spurious warnings on load
  . "$NVM_DIR/nvm.sh" &> /dev/null
fi

# Golang setup
set-if-exists GOPATH "${HOME}/go"
[[ -n "${GOPATH}" ]] && add-path-if-exists "${GOPATH}/bin"

# For some reason, the Go AWS SDK in particular refuses to load profiles and
# credentials correctly without this, which includes terraform
export AWS_SDK_LOAD_CONFIG=1

# Python packaging framework
add-path-if-exists "${HOME}/.poetry/bin"

# kubectl krew plugin manager
add-path-if-exists "${HOME}/.krew/bin"

#export RUST_SRC_PATH="/Users/jasonmiller/github/rust/src"

#eval "$(pyenv init -)"
#eval "$(pyenv virtualenv-init -)"

# Travis setup
#source-if-exists "${HOME}/.travis/travis.sh"

# Personal pyw wrapper helper
source-if-exists "${HOME}/github/stormbeta/snippets/python/pyw/pyw.bashrc"

# Android SDK paths
#(set-if-exists ANDROID_HOME "${HOME}/Library/Android/sdk" \
  #|| set-if-exists ANDROID_HOME "${HOME}/.android-sdk") \
  #&& add-path-if-exists "${ANDROID_HOME}/platform-tools"

# Google Cloud SDK setup
# TODO: is there a standard place the SDK is installed to besides home?
#if [[ -d "${HOME}/google-cloud-sdk" ]]; then
  #export GOOGLE_CLOUD_HOME="${HOME}/google-cloud-sdk"
  #source-if-exists "${GOOGLE_CLOUD_HOME}/path.${SHELL_NAME}.inc"
  #source-if-exists "${GOOGLE_CLOUD_HOME}/completion.${SHELL_NAME}.inc"
#fi
