list-mediapath() {
 (unset CMD
  while :; do
    case "$1" in
      -b|-c|-d|-e|-f|-g|-h|-k|-L|-N|-O|-p|-r|-s|-x) FILTER="${FILTER:+$FILTER | }filter-test $1"; shift ;;
      -m|--mixed|-M|--mode|-u|--unix|-w|--windows|-a|--absolute|-l|--long-name) PATHTOOL_OPTS="${PATHTOOL_OPTS:+PATHTOOL_OPTS }$1"; shift ;;
      -*) OPTS="${OPTS:+$OPTS }$1"; shift ;;
      --) shift; break ;;
      *) break ;;
      esac
  done
  for ARG; do ARG=${ARG//" "/"\\ "}; ARG=${ARG//"("/"\\("};  ARG=${ARG//")"/"\\)"}; 
   CMD="${CMD:+$CMD; }ls -1 -d $OPTS -- $MEDIAPATH/${ARG#/} 2>/dev/null"; done

  [ -n "$PATHTOOL_OPTS" ] && CMD="${PATHTOOL:+$PATHTOOL ${PATHTOOL_OPTS:--m}}${PATHTOOL:-realpath} \$($CMD)"
  #CMD="for ARG; do $CMD; done"
  [ -n "$FILTER" ] &&	 CMD="($CMD) | $FILTER"
[ "$DEBUG" = true ] && echo "CMD: $CMD" 1>&2
  eval "$CMD")
}
