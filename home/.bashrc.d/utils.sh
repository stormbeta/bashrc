# Compatible with bash and zsh

function _log-warn {
  local msg="[WARN]: $0: $*"
  echo "$(date) ${msg}" >> ~/.bash_warnings
  if [[ -n "$SHELL_INIT_DEBUG" ]]; then
    echo "$msg" 1>&2
  fi
}

function path-exists {
  local check_path="$1"
  [[ -e "$check_path" ]]
  return $?
}

set-if-exists() {
  local var_name="$1"
  local check_path="$2"
  if path-exists "${check_path}"; then
    #typeset -x doesn't work
    eval "export ${var_name}=${check_path}"
  fi
}

function add-path-if-exists {
  local check_path="$1"
  if path-exists "$check_path"; then
    path-prepend "$check_path"
  fi
}

function source-if-exists {
  local check_path="$1"
  if path-exists "$check_path"; then
    source "$check_path"
  fi
}

if [[ -n "$BASH_VERSION" ]]; then
  # Needed to preserve completion on aliases with arguments
  # Based on https://unix.stackexchange.com/questions/4219/how-do-i-get-bash-completion-for-command-aliases
  function make-completion-wrapper {
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
  # Supports command + args
  # Usage: complete-alias ALIAS command...
  function complete-alias {
    local al="$1"
    shift 1
    local compfunc="$(complete | grep '\-F' | grep -Eo "\w+ ${1}\$" | awk '{$NF="";sub(/[ \t]+$/,"")}1')"
    # TODO: Verify this isn't already taken
    local alcomp="___${al}"
    make-completion-wrapper "${compfunc}" "${alcomp}" $@
    eval "alias ${al}='$@'"
    complete -o default -F "${alcomp}" "${al}"
  }
else
  # zsh seems to handle completion in aliases correctly out of the box
  function complete-alias {
    local a="$1"
    shift 1
    alias "${a}=$*"
  }
fi