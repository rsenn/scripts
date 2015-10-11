 grep-in-index() {
  (CMD='index-dir -u $DIRS | xargs grep "[^/]\$" -H | sed "s|^$PWD/files.list:|| ; s|/files.list:|/|" -u | xargs grep $OPTS -H -E "($EXPRS)" '
#   case "$PATHTOOL" in
#     cygpath*) PATHTOOL="xargs $PATHTOOL" ;;
#   esac
   while :; do
     case "$1" in
#       -w | -m) CMD="$CMD | ${PATHTOOL:-xargs cygpath} $1"; shift ;;
       -A|-B|-C|-D|-E|-F|-G|-H|-I|-L|-NUM|-P|-R|-T|-U|-V|-Z|-a|-b|-c|-d|-e|-f|-h|-i|-l|-m|-n|-o|-q|-r|-s|-u|-v|-w|-x|-z|\
       --color|--basic-regexp|--binary|--byte-offset|--count|--dereference-recursive|--extended-regexp|--files-with-matches|--files-without-match|--fixed-strings|--help|--ignore-case|--initial-tab|--invert-match|--line-buffered|--line-number|--line-regexp|--no-filename|--no-messages|--null|--null-data|--only-matching|--perl-regexp|--quiet|--recursive|--silent|--text|--unix-byte-offsets|--version|--with-filename|--word-regexp) OPTS="${OPTS:+$OPTS
}$1"; shift ;;
       --*=*) OPTS="${OPTS:+$OPTS
}$1
$2"; shift 2 ;;
       *) break ;;
     esac
    done


  while [ $# -gt 0 ]; do
    if [ -d "$1" ]; then
      pushv DIRS "$1"
    else
      EXPRS="${EXPRS:+$EXPRS|}$1"
    fi
    shift
  done
  eval "$CMD"
)
}

