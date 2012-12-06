#!/bin/bash

function dup () {
  local path=$1
  local new=$2

  cp "${path}" $(dirname ${path})/${new}
}

function path() {
    old=$IFS
    IFS=:
    printf "%s\n" $PATH
    IFS=$old
}

function pathmunge () {
  if [[! echo ${PATH} | /bin/egrep -q "(^|:)${1}($|:)" ]]; then
     if [[ "${2}" = "after" ]] ; then
      PATH=${PATH}:${1}
  else
      PATH=${1}:${PATH}
  fi
fi
}