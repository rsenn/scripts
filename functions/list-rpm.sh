list-rpm() {
 (NARG=$#
  output() {
    if [ -n "$*" -a "$#" -gt 0 ]; then
      [ "$NARG" -gt 1 ] && echo "$ARG: $*" || echo "$*"
    fi
  }
  LOG="$PWD/$(basename "$0" .sh).log"
  exec_cmd() {
   (
    echo "CMD: $@" 1>&2
    echo "CMD: $@" >>"$LOG"
    exec "$@")
  }
  for ARG in "$@"; do
   (set -e
    trap 'rm -rf "$TEMP"' EXIT QUIT TERM INT
    TEMP=$(mktemp -d "$PWD/${0##*/}-XXXXXX")
    mkdir -p "$TEMP"
    case "$ARG" in
      *://*)
        if type wget >/dev/null 2>/dev/null; then
          exec_cmd wget -P "$TEMP" -q "$ARG"
        elif type curl >/dev/null 2>/dev/null; then
          exec_cmd curl -s -k -L -o "$TEMP/${ARG##*/}" "$ARG"
        elif type lynx >/dev/null 2>/dev/null; then
          exec_cmd lynx -source >"$TEMP/${ARG##*/}" "$ARG"
        fi || exit $?
        RPM="${ARG##*/}"
      ;;
      *) RPM=$(realpath "$ARG") ;;
    esac
    cd "$TEMP"
    set -- $( (    7z l "$RPM" |${SED-sed} -n "\$d; /^----------/ { n; /^------------------/ { :lp; \$! { d; b lp; }; } ; /^-/! { / files\$/! s|^...................................................  ||p }; }"  ||
    (exec_cmd "${RPM2CPIO-rpm2cpio}" >/dev/null; R=$?; [ $R -eq 0 ] && echo "$(basename "$RPM" .rpm).cpio"; exit $R) ) 2>/dev/null |uniq |grep "\\.cpio\$")
    if [ $# -le 0 ]; then
      exit 1
    fi
    CPIOCMD="exec_cmd cpio -t 2>/dev/null"
    case "$1" in
      *.bz2) CPIOCMD="bzcat | $CPIOCMD" ;;
      *.xz) CPIOCMD="xzcat | $CPIOCMD" ;;
      *.gz) CPIOCMD="zcat | $CPIOCMD" ;;
      *.cpio) ;;
    esac
    ((set -x; exec_cmd 7z x -so "$RPM" "$1" ) ||
   { exec_cmd "${RPM2CPIO-rpm2cpio}" <"$RPM"; }
     ) 2>/dev/null |
    eval "$CPIOCMD" | while read -r LINE; do
      case "$LINE" in
        ./) LINE="/" ;;
        ./?*) LINE="${LINE#./}" ;;
      esac
      output "$LINE"
    done) ||
    output "ERROR" 1>&2
  done)
}
