list-deb() {
 (trap 'exit 1' INT
  NARG=$#
  output() {
    if [ -n "$*" -a "$#" -gt 0 ]; then
      [ "$NARG" -gt 1 ] && echo "$ARG: $*" || echo "$*"
    fi
  }
  for ARG in "$@"; do
   (set -e
    trap 'rm -rf "$TEMP"' EXIT
    TEMP=$(mktemp -d "$PWD/${0##*/}-XXXXXX")
    mkdir -p "$TEMP"
    case "$ARG" in
      *://*)
        if type wget >/dev/null 2>/dev/null; then
          wget -P "$TEMP" -q "$ARG"
        elif type curl >/dev/null 2>/dev/null; then
          curl -s -k -L -o "$TEMP/${ARG##*/}" "$ARG"
        elif type lynx >/dev/null 2>/dev/null; then
          lynx -source >"$TEMP/${ARG##*/}" "$ARG"
        fi || exit $?
        DEB="${ARG##*/}"
      ;;
      *) DEB=$(realpath "$ARG") ;;
    esac
    cd "$TEMP"
    set -- $( ("${AR-ar}" t "$DEB" || list-7z "$DEB") 2>/dev/null |uniq |${GREP-grep
-a
--line-buffered
--color=auto} "data\.tar\.")
    if [ $# -le 0 ]; then
      exit 1
    fi
    case "$1" in
      *.bz2) TAR_ARGS="-j" ;;
      *.xz) TAR_ARGS="-J" ;;
      *.gz) TAR_ARGS="-z" ;;
      *.tar) TAR_ARGS="" ;;
    esac

   ( { "${AR-ar}" x "$DEB" "$1"; test -e "$1"; } ||
    7z x "$DEB" "$1") 2>/dev/null
    "${TAR-tar}" $TAR_ARGS -t -f "$1" 2>/dev/null | while read -r LINE; do
      case "$LINE" in
        ./) LINE="/" ;;
        ./?*) LINE="${LINE#./}" ;;
      esac
      output "$LINE"
    done) ||
    output "ERROR" 1>&2
  done)
}
