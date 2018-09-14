#!/usr/bin/env bash
#TODO: Verify that I can bootstrap without a seed machine
case $PLATFORM in
  darwin)
    function upgrade-all {
      # Upgrade homebrew, os patches, and appstore applications (requires mas)
      if command -v brew &>/dev/null; then
        brew upgrade && brew cask upgrade
        if command -v mas &>/dev/null; then
          mas upgrade
        else
          echo "Mas not installed, can't update AppStore apps from CLI" 1>&2
        fi
        sudo softwareupdate -dia
      fi
      #command -v npm &> /dev/null && npm update npm -g && npm update -g
      #command -v gem &> /dev/null && sudo gem update
    }
    ;;
  linux)
    function updateplatform {
      # Update all teh Linux things.
      command -v apt-get &>/dev/null && sudo apt-get update && sudo apt-get upgrade
      command -v yum &> /dev/null && sudo yum update && sudo yum upgrade
      command -v npm &> /dev/null && npm update npm -g && npm update -g
      command -v gem &> /dev/null && sudo gem update
    }
    ;;
  *)
    function updateplatform {
      # TODO: support chocolatey on windows?
      #       though bash on windows these days is normally ran via WSFL, which would report as Linux
      echo " I don't know how to update things on this platform (${PLATFORM})."
    }
    ;;
esac

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

# TODO: This needs updating
#function ssh-init-home {
  #local target
  #for target in $@; do
    #ssh-copy-id ${target}
    ##TODO: Replace scp with rsync
    #scp ~/.ssh/known_hosts ${target}:./.ssh/known_hosts
    #scp -r "${HOME}/.homesick" ${target}:./
    #scp -r "${HOME}/.homeshick" ${target}:./

    #ssh -At ${target} bash <<EOF
      #export HOMESICK="\${HOME}/.homesick/repos"
      #export HOMESHICK="\${HOMESICK}/homeshick"
      #export HOMESICK_REPOS="${HOMESICK_REPOS}"
      #export HOMESICK_MKDIRS="${HOMESICK_MKDIRS}"
      #ssh-keyscan github.com >> ~/.ssh/known_hosts
      #$(declare -f updatehome)
      #updatehome

#EOF
    #rsync -az "${HOME}/.vim/bundle" ${target}:.vim/
  #done
#}

# vim: set ft=sh ts=2 sw=2 tw=0 :
