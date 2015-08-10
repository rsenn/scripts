list-deb() { 
  NARG=$#
  output() {
    if [ -n "$*" -a "$#" -gt 0 ]; then
      [ "$NARG" -gt 1 ] && echo "$ARCHIVE: $*" || echo "$*"
    fi
  }
	for ARG in "$@"; do
   (trap 'rm -rf "$TMPDIR"' EXIT QUIT TERM INT
    TMPDIR=$(mktemp -d)
    mkdir -p "$TMPDIR"
    ABSPATH=$(realpath "$ARG")
    cd "$TMPDIR"
    ar x "$ABSPATH"
    set -- data.*
    tar -tf "$1" | while read -r LINE; do
      LINE=${LINE#./}
      case "$LINE" in
        "") continue ;;
        *) output "$LINE" ;;
      esac
		done)
  done
}
