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

function git-lastauthor {
  while read line; do
    local hash=$(git log -n 1 --pretty=format:%H "$line")
    echo "${line} $(git show -q --format="%ai %ar by %an" ${hash})"
  done
}

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


# Gitlab-specific
# NOTE: clone expects ssh config named 'gitlab' to work
function gl-clone {
  cd "${HOME}/ping"
  local project_path="$1"
  shift 1
  git clone "ssh://gitlab/${project_path}" "$project_path" "$@"
  local result=$?
  cd "$project_path"
  [[ $? -eq 128 ]] && (git fetch --all && git pull --rebase)
}

function gitlab-url {
  git config --get remote.origin.url | sed -E "s~((ssh://[^/]+/)|(git@)?gitlab[^:]+:)~~;s/\.git$//;s|^|${GITLAB_URL}/|"
}

function glp {
  # TODO: Make it default target to default branch, allow title override
  local title="$(git log -1 --pretty=%s)"
  local description="$(git log -1 --pretty=%b)"
  git log -1 --pretty=%B
  read -p "Push and create MR? [Y/n]" -n 1 -r prompt
  echo "$1 $prompt"
  if [[ ! $prompt =~ ^[Yy]$ ]]; then
    echo "Aborting!" 1>&2
    return 1
  else
    if [[ -n "$description" ]]; then
      git push -o merge_request.create -o merge_request.target="${1:-master}" -o merge_request.title="${title}" -o merge_request.description="${description}"
    else
      git push -o merge_request.create -o merge_request.target="${1:-master}" -o merge_request.title="${title}"
    fi
  fi
}
