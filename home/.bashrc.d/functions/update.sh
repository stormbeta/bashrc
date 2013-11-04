case ${PLATFORM} in
  darwin)
    function updateplatform {
      # Update all teh OSX things.
      sudo softwareupdate -i -a
      if which brew &> /dev/null; then
        brew update
        brew upgrade
        brew cleanup
      fi
      which npm &> /dev/null && npm update npm -g && npm update -g
      which gem &> /dev/null && sudo gem update
    }
    ;;
  linux)
    function updateplatform {
      # Update all teh Linux things.
      which apt-get &>/dev/null && sudo apt-get update && sudo apt-get upgrade
      which yum &> /dev/null && sudo yum update && sudo yum upgrade
      which npm &> /dev/null && npm update npm -g && npm update -g
      which gem &> /dev/null && sudo gem update
    }
    ;;
  *)
    function updateplatform {
      echo " I don't know how to update all teh things on this platform (${PLATFORM})."
    }
    ;;
esac

function updatehome {
  # Initialize homesick if needed.
  if [[ ! -d "${HOMESHICK}" ]]; then
    git clone git://github.com/andsens/homeshick.git ${HOMESHICK}
  fi

  source "${HOMESHICK}/homeshick.sh"
  for dir in ${HOMSICK_MKDIRS}; do mkdir -p ${dir}; done
  for repo in ${HOMESICK_REPOS}; do homeshick clone ${repo}; done

  # Update homesick repos.
  homeshick pull && homeshick symlink
  source ${HOME}/.bashrc
  ( cd ${HOME}/.vim; make install )
}

function update {
  updateplatform
  updatehome
}

function ssh-init-home {
  local target=${1}

  ssh-copy-id ${target}
  ssh -At ${target} bash <<EOF
    export HOMESHICK="${HOMESHICK}"
    export HOMESICK_REPOS="${HOMESICK_REPOS}"
    export HOMESICK_MKDIRS="${HOMESICK_MKDIRS}"
    $(declare -f updatehome)
    updatehome
EOF
}

# vim: set ft=sh ts=2 sw=2 tw=0 :
