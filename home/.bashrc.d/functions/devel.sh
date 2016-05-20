function autorun-file {
  # Executes a command everytime a file or directory's contents change
  # Useful for iterative development
  if [[ -z "$(which inotifywait)" ]]; then
    echo "inotify-tools not installed, cannot execute" >&2
  fi

  path="$1"
  shift
  while true; do
    inotifywait -q -e close_write,create ${path}
    $@
  done
}

function stash-clone {
  git clone "ssh://git@stash.ecovate.com/$1"
}

function gh-clone {
  GIT_COMMITTER_EMAIL='stormbeta@gmail.com' GIT_AUTHOR_EMAIL='stormbeta@gmail.com' git clone "git@github.com:$1.git"
}
