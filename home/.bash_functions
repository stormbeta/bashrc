function bkup {
  # Make a copy of the path to *_bkup.
  local path=${1}
  local bkup=${path}_bkup

  if [[ -e "${path}" ]]; then
    cp -a "${path}" "${bkup}"
  fi
}

function restore {
  # Restores a _bkup dir/file.
  local bkup=${1}
  local new=${1%_bkup}

  if [[ -e "${bkup}" ]]; then
    [ ! -f ${new} ] && mkdir ${new}
    diff "${bkup}" "${new}"
    cp -i "${bkup}" "${new}"
    rm -rf "${bkup}"
  fi
}

function jarls {
  jar tvf ${1}
}

function tarls {
  tar tvzf ${1} | tarcolor
}

# vim: set ft=sh ts=2 sw=2 tw=0 :
