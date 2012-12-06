#!/bin/bash

# Make a copy of the path right beside it. 
function dup () {
  local path=${1}
  local new=${2}

  cp "${path}" $(dirname ${path})/${new}
}

# Print out the current path in a nice way
function path() {
    local IFS=: && printf "%s\n" ${PATH}
}

# Lets be smart about how we add new stuff to our PATH
function pathmunge () {
  if ! echo ${PATH} | /bin/grep -qe "(^|:)${1}($|:)" ; then
     if [[ "${2}" = "after" ]] ; then
      PATH=${PATH}:${1}
  else
      PATH=${1}:${PATH}
  fi
fi
}