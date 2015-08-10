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
		set -- $("${AR-ar}" t "$ABSPATH" 2>/dev/null |grep '^data\.')
		if [ $# -le 0 ]; then
			output "ERROR" 1>&2 
			continue
		fi
		case "$1" in
			*.bz2) TAR_ARGS="-j" ;;
			*.xz) TAR_ARGS="-J" ;;
			*.gz) TAR_ARGS="-z" ;;
		esac
    "${AR-ar}" x "$ABSPATH" "$1" 2>/dev/null
    "${TAR-tar}" $TAR_ARGS -t -f "$1" 2>/dev/null | while read -r LINE; do
			case "$LINE" in
				./) LINE=/ ;;
				./?*) LINE=${LINE#./} ;;
			esac
      output "$LINE"
		done)
  done
}
