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
#function glc {
  #git log --graph --full-history --all --color --pretty=format:"%x1b[31m%h%x09%x1b[32m%d%x1b[0m%x20%s" "$@"
#}

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

# Clone project from gerrit (based on ssh config) and jump to directory
function gr-clone {
  cd "${HOME}/ping"
  local project_path="$1"
  shift 1
  git clone "ssh://gerrit/${project_path}" "$project_path" "$@"
  cd "$project_path"
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
  [[ $? -eq 128 ]] && (git fetch --all && git pull --rebase)
}

function gitlab-url {
  git config --get remote.origin.url | sed -E "s~((ssh://[^/]+/)|(git@)?gitlab[^:]+:)~~;s/\.git$//;s|^|${GITLAB_URL}/|"
}

# Gitlab shortcuts for opening project pages
# NOTE: expects GITLAB_URL and GITLAB_TOKEN to be defined
if [[ -f "${HOME}/.secret/gitlab" ]]; then
  source "${HOME}/.secret/gitlab"
  export GITLAB_URL="${GITLAB_URL:-https://gitlab.corp.pingidentity.com}"

  function gitlab-project {
    git config --get remote.origin.url | sed -E 's~((ssh://[^/]+/)|(git@)?gitlab[^:]+:)~~;s/\.git$//'
  }

  function gitlab-api {
    local path="$(echo "$*" | sed -E "s/(\?|$)/\?private_token=${GITLAB_TOKEN}\&/")"
    echo "$(gitlab-project | sed -E "s|/|%2F|g;s|^|${GITLAB_URL}/api/v4/projects/|")${path}"
  }

  alias glme='open -a Firefox "$(curl -s "$(gitlab-api "/merge_requests?source_branch=$(git rev-parse --abbrev-ref HEAD)")" | jq -r ".[].web_url")"'
  alias glm='open -a Firefox "$(gitlab-url)/merge_requests"'

  # Find project by name, and use fzf to narrow if multiple matches found
  function gl-project {
    local results="$(curl -H "PRIVATE-TOKEN: $GITLAB_TOKEN" "${GITLAB_URL}/api/v4/search?scope=projects&search=${1}" -s)"
    local project="$(echo "$results" | jq --arg project "$1" '.[] | select(.path == $project) | .path_with_namespace' -r)"
    if [[ -z "$project" ]]; then
      project="$(echo "$results" | jq --arg project "$1" '.[] | select(.path_with_namespace | contains($project)) | .path_with_namespace' -r)"
    fi
    echo "$project" | fzf -1
  }

  # Clone project from gitlab based on fuzzy match from name passed to function, then jump to
  # directory and pull any changes
  function glc {
    gl-clone "$(gl-project "$1")"
    git fetch --all && git co master && git pull
  }

  # Open current project in browser, or else attempt to match project name passed to function
  function glo {
    if [[ "$#" == 0 ]]; then
      open -a Firefox "$(gitlab-url)"
    else
      open -a Firefox "${GITLAB_URL}/$(gl-project "$1")"
    fi
  }
fi

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
