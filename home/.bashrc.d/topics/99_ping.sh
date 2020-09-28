#!/usr/bin/env bash

function git-project-path {
  git config --get remote.origin.url | sed -E 's`((ssh://[^/]+/)|(git@)?[^:]+:)``;s/\.git$//'
}

export AWS_PROFILE=devtools

alias ji='open -a Firefox "https://jenkins-infra.pingdev.tools/job/$(git-project-path | sed -E "s|/|/job/|g")"'
alias jics='open -a Firefox "https://jenkins-icecream.pingdev.tools/job/$(git-project-path | sed -E "s|/|/job/|g")"'

# Map kubectl proxy shortcuts for faster response times
complete-alias kl kubectl --server=127.0.0.1:8001
complete-alias klp kubectl --server=127.0.0.1:8002
complete-alias klc kubectl --server=127.0.0.1:8003
complete-alias klt kubectl --server=127.0.0.1:8004
complete-alias klo kubectl --server=127.0.0.1:8005
complete-alias kle kubectl --server=127.0.0.1:8007
complete-alias klm kubectl --context=minikube

alias vlp='VAULT_ADDR="https://prod-vault-us-east-2.awscloud.pingidentity.net" vault-wrapper'
alias vlw='VAULT_ADDR="https://prod-vault-us-west-2.awscloud.pingidentity.net" vault-wrapper'
alias vle='VAULT_ADDR="https://prod-vault-eu-central-1.awscloud.pingidentity.net" vault-wrapper'
alias vlow='VAULT_ADDR="https://nonprod-vault-us-west-2.awscloud.pingidentity.net" vault-wrapper'
alias vlo='VAULT_ADDR="https://nonprod-vault-us-east-2.awscloud.pingidentity.net" vault-wrapper'
alias vlt='VAULT_ADDR="https://nonprod-vault-us-east-2.awscloud.pingidentity.net" vault-wrapper'
alias vla='VAULT_ADDR="https://prod-vault-ap-southeast-2.awscloud.pingidentity.net" vault-wrapper'
alias vl='VAULT_ADDR="http://localhost:8200" VAULT_TOKEN="vault-token" vault-wrapper'

# Open project's jenkins builds if known
# NOTE: HACKY HACK - depends on pre-generated mappings
function glj {
  local project
  if [[ -n "$1" ]]; then
    project="$(gl-project "$1")"
  else
    project="$(git config --get remote.origin.url | sed -E 's~((ssh://[^/]+/)|(git@)?gitlab[^:]+:)~~;s/\.git$//')"
  fi
  local url="https://gitlab.corp.pingidentity.com/${project}"
  local target="$(jq --arg gitlab "$url" '.[]|select(.gitlab_url == $gitlab) | .job_url' -r "${HOME}/.jenkins-icecream.pingdev.tools.json" | fzf -1)"
  if [[ -n "$target" ]]; then
    open -a Firefox "$target"
  else
    echo "No projects or none selected!" 1>&2
  fi
}
