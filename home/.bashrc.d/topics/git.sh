#!/usr/bin/env bash
# Change git author information if I am at work.
if [[ "${PLATFORM}" == "cygwin" ]]; then
  hostname="${COMPUTERNAME}.${USERDNSDOMAIN}"
else
  hostname=$(hostname -f)
fi

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

# Fancy git color log
function glc {
  git log --graph --full-history --all --color --pretty=format:"%x1b[31m%h%x09%x1b[32m%d%x1b[0m%x20%s" "$@"
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

function gh-clone {
  cd "${HOME}/github"
  GIT_COMMITTER_EMAIL='stormbeta@gmail.com' \
    GIT_AUTHOR_EMAIL='stormbeta@gmail.com' \
    git clone "git@github.com:$1.git" "$1"
  cd "$1"
}

function gr-clone {
  git clone "ssh://gerrit/$1" $1
}

alias gpf='git fetch --all && git pull --rebase || git pull --ff-only'
alias gfp='gpf'
alias gh="GIT_COMMITTER_EMAIL='stormbeta@gmail.com' GIT_AUTHOR_EMAIL='stormbeta@gmail.com' git"

# Gitlab-specific
# NOTE: clone expects ssh config named 'gitlab' to work
function gl-clone {
  cd "${HOME}/ping"
  local project_path="$1"
  shift 1
  git clone "ssh://gitlab/${project_path}" "$project_path" "$@"
  local result=$?
  cd "$project_path"
  [[ $? -eq 128 ]] && (git fetch --all && git pull)
}

function gitlab-url {
  git config --get remote.origin.url | sed -E "s~((ssh://[^/]+/)|(git@)?gitlab[^:]+:)~~;s/\.git$//;s|^|${GITLAB_URL}/|"
}

# Gitlab shortcuts for opening project pages
# NOTE: expects GITLAB_URL and GITLAB_TOKEN to be defined
if [[ -f "${HOME}/.secret/gitlab" ]]; then
  source "${HOME}/.secret/gitlab"
  function gitlab-api {
    local path="$(echo "$*" | sed -E "s/(\?|$)/\?private_token=${GITLAB_TOKEN}\&/")"
    echo "$(git config --get remote.origin.url | sed -E "s~((ssh://[^/]+/)|(git@)?gitlab[^:]+:)~~;s/\.git$//;s|/|%2F|g;s|^|${GITLAB_URL}/api/v4/projects/|")${path}"
    #echo "$(git config --get remote.origin.url | sed -E "s|/|\%2F|g;s|(git@)?gitlab[^:]+:|${GITLAB_URL}/api/v4/projects/|;s/\.git$//")${path}"
  }
  alias glme='open -a Firefox "$(curl -s "$(gitlab-api "/merge_requests?source_branch=$(git rev-parse --abbrev-ref HEAD)")" | jq -r ".[].web_url")"'
  alias glo='open -a Firefox "$(gitlab-url)"'
  alias glm='open -a Firefox "$(gitlab-url)/merge_requests"'
fi
