function watch-file {
  # Executes a command everytime a file or directory's contents change
  # Useful for iterative development
  local platform=$(uname ${uname_flag} | tr "[:upper:]" "[:lower:]")
  local path="$1"
  shift
  case $platform in
    darwin)
      if ! command -v fswatch; then
        echo "fswatch not installed, cannot execute" >&2
        exit 1
      fi
      fswatch "${path}" | xargs -n1 -I{} $@
      ;;
    *)
      if ! command -v inotify-wait; then
        echo "inotify-tools not installed, cannot execute" >&2
        exit 1
      fi
      while true; do
        inotifywait -q -e close_write,create ${path}
        $@
      done
      ;;
  esac
}

function gh-clone {
  GIT_COMMITTER_EMAIL='stormbeta@gmail.com' GIT_AUTHOR_EMAIL='stormbeta@gmail.com' git clone "git@github.com:$1.git" $1
}

#Set sudo ticket via lastpass-cli
function lpw-sudo {
  local password_id="${1:-sudo}"
  lpass show --password "${password_id}" | sudo -Sv
}
