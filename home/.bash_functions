function jarls {
  jar tvf ${1}
}

function tarls {
  tar tvzf ${1} | tarcolor
}

# vim: set ft=sh ts=2 sw=2 tw=0 :
