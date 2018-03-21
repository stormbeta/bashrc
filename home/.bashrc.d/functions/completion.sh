# Based on https://unix.stackexchange.com/questions/4219/how-do-i-get-bash-completion-for-command-aliases
function make-completion-wrapper () {
  local function_name="$2"
  local arg_count=$(($#-3))
  local comp_function_name="$1"
  shift 2
  local function="
  function $function_name {
    ((COMP_CWORD+=$arg_count))
    COMP_WORDS=( "$@" \${COMP_WORDS[@]:1} )
    "$comp_function_name"
    #return 0
  }"
  eval "$function"
}

# *actually* alias a command, with real completion intact
function complete-alias {
  local al="$1"
  shift 1
  # TODO: fix sed command to be more portable
  local compfunc="$(complete | grep '\-F' | grep -oP "\w+ ${1}\$" | gsed -r 's/ [^\s]+$//')"
  # TODO: Verify this isn't already taken
  local alcomp="___${al}"
  make-completion-wrapper "${compfunc}" "${alcomp}" $@
  eval "alias ${al}='$@'"
  complete -o default -F "${alcomp}" "${al}"
}
