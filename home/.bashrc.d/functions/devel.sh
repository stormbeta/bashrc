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
