__profile "${BASH_SOURCE[0]}"
# TODO: Probably superceded by the loopit script?
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
