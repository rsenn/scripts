list-deb() { 
  NARG=$#
  output() {
    if [ -n "$*" -a "$#" -gt 0 ]; then
      [ "$NARG" -gt 1 ] && echo "$ARG: $*" || echo "$*"
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
			case "$LINE" in
				./?*) LINE=${LINE#./}
			esac
      case "$LINE" in
        *) output "$LINE" ;;
      esac
		done)
  done
}
