# Paths and setup for various CLI tools and utitlies

# Ruby Version Manager
if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
  source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
  path-prepend "${HOME}/.rvm/bin"
fi

# NodeJS Version Manager
if [[ -f "${HOME}/.nvm/nvm.sh" ]]; then
  export NVM_DIR="${HOME}/.nvm"
  # nvm insists on spamming spurious warnings on load
  . "$NVM_DIR/nvm.sh" &> /dev/null
fi

# Golang setup
set-if-exists GOPATH "${HOME}/go"
if [[ -n "${GOPATH}" ]]; then
  add-path-if-exists "${GOPATH}/bin"
fi

# For some reason, the Go AWS SDK in particular refuses to load profiles and
# credentials correctly without this, which includes terraform
export AWS_SDK_LOAD_CONFIG=1

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

# kubectl krew plugin manager
if [[ -d "${HOME}/.krew/bin" ]]; then
  export PATH="${HOME}/.krew/bin:${PATH}"
fi
