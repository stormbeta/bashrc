#!/usr/bin/env bash
__profile "${BASH_SOURCE[0]}"

# cd relative to nearest git root
function gcd {
  if command -v git &> /dev/null; then
    local STATUS=$(git status 2>/dev/null)
    if [[ -z ${STATUS} ]]; then
      return;
    fi
    local dir="./$( command git rev-parse --show-cdup )/${1}"
    cd "${dir}"
  fi
}

function _git_cd {
  if $(which git &> /dev/null); then
    STATUS=$(git status 2>/dev/null)
    if [[ -z ${STATUS} ]]; then
      return
    fi
    TARGET="./$( command git rev-parse --show-cdup )"
    if [[ -d $TARGET ]]; then
      TARGET="$TARGET/"
    fi
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}$2"
    opts=$(cd $TARGET; compgen -d -o dirnames -S / -X '@(*/.git|*/.git/|.git|.git/)' $2)
    if [[ ${cur} == * ]]; then
      COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
      return 0
    fi
  fi
}

complete -o nospace -F _git_cd gcd

#TODO: Find a way to dynamically set this by repository, not just host/id
#if [[ ${hostname} =~ .+\.(example)\.com ]] || \
   #[[ `id` =~ 'EXAMPLE' ]]; then
  #export GIT_AUTHOR_EMAIL="jason.miller@example.com"
  #export GIT_COMMITTER_EMAIL=${GIT_AUTHOR_EMAIL}
#fi

# Clone project from github and jump to directory
function gh-clone {
  cd "${HOME}/github"
  GIT_COMMITTER_EMAIL='stormbeta@gmail.com' \
    GIT_AUTHOR_EMAIL='stormbeta@gmail.com' \
    git clone "git@github.com:$1.git" "$1"
  cd "$1"
}

function gfp {
  git fetch --all
  local remote="$(git rev-parse --abbrev-ref HEAD@{upstream} 2>/dev/null)"
  git log --pretty=oneline --abbrev-commit "HEAD..${remote}"
  git pull --rebase || git pull --ff-only
}

alias gpf='gfp'
alias g='git'
alias gh="GIT_COMMITTER_EMAIL='stormbeta@gmail.com' GIT_AUTHOR_EMAIL='stormbeta@gmail.com' git"
if [[ "$USER" != 'jasonmiller' ]]; then
  GIT_COMMITTER_EMAIL='stormbeta@gmail.com'
  GIT_AUTHOR_EMAIL='stormbeta@gmail.com'
fi
