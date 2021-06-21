#!/usr/bin/env bash
export PLATFORM="$(uname -s | tr "[:upper:]" "[:lower:]")"
case $PLATFORM in
  darwin)
    function upgrade-all {
      # Upgrade homebrew, os patches, and appstore applications (requires mas)
      if command -v brew &>/dev/null; then
        brew upgrade && brew upgrade --cask
        # TODO: this doesn't really update anything I care about
        #if command -v mas &>/dev/null; then
          #mas upgrade
        #else
          #echo "Mas not installed, can't update AppStore apps from CLI" 1>&2
        #fi
        sudo softwareupdate -dia
      fi
      #pip3 list | grep -Eo '^\w+' | xargs -n1 -I{} pip3 install --upgrade '{}'
      #command -v npm &> /dev/null && npm update npm -g && npm update -g
      #command -v gem &> /dev/null && sudo gem update
    }
    ;;
  linux)
    function upgrade-all {
      command -v apt-get &>/dev/null && sudo apt-get update && sudo apt-get upgrade
      command -v yum &> /dev/null && sudo yum update && sudo yum upgrade
      command -v brew &> /dev/null && brew upgrade
      #command -v npm &> /dev/null && npm update npm -g && npm update -g
      #command -v gem &> /dev/null && sudo gem update
    }
    ;;
  *)
    function upgrade-all {
      # TODO: support chocolatey on windows?
      #       though bash on windows these days is normally ran via WSFL, which would report as Linux
      echo " I don't know how to update things on this platform (${PLATFORM})."
    }
    ;;
esac

# TODO: Factor out into stand-alone script
function updatehome {
  # Initialize homesick if needed.
  set -e
  if [[ ! -d "${HOMESHICK}" ]]; then
    git clone git://github.com/andsens/homeshick.git ${HOMESHICK}
  fi

  source "${HOMESHICK}/homeshick.sh"

  local dir
  local full_dir
  for dir in "${HOMESICK_MKDIRS[@]}"; do
    full_dir="${HOME}/${dir}"
    if [[ ! -d ${full_dir} ]]; then
      echo "Creating ${full_dir}."
      mkdir -p ${HOME}/${dir}
    else
      echo "${full_dir} exists."
    fi
  done

  set +e
  for repo in ${HOMESICK_REPOS}; do homeshick clone git@github.com:${repo}; done
  set -e

  # Update homesick repos.
  homeshick pull
  yes | homeshick symlink

  source ${HOME}/.bashrc
  set +e
  ( cd ${HOME}/.vim; ./update.sh )
}

# vim: set ft=sh ts=2 sw=2 tw=0 :
