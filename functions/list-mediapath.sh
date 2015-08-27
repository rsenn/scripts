list-mediapath() {
 (while :; do
		case "$1" in
		  -b|-c|-d|-e|-f|-g|-h|-k|-L|-N|-O|-p|-r|-s|-x) FILTER="${FILTER:+$FILTER | }filter-test $1"; shift ;;
		  -m|--mixed|-M|--mode|-u|--unix|-w|--windows|-a|--absolute|-l|--long-name) PATHTOOL_OPTS="${PATHTOOL_OPTS:+PATHTOOL_OPTS }$1"; shift ;;
			-*) OPTS="${OPTS:+$OPTS }$1"; shift ;;
			--) shift; break ;;
			*) break ;;
			esac
	done
	for ARG; do CMD="${CMD:+$CMD; }ls -1 -d $OPTS -- $MEDIAPATH/${ARG#/} 2>/dev/null"; done
	
	[ -n "$PATHTOOL_OPTS" ] && CMD="$PATHTOOL ${PATHTOOL_OPTS:--m} \$($CMD)"
	#CMD="for ARG; do $CMD; done"
	[ -n "$FILTER" ] &&	 CMD="($CMD) | $FILTER"
	echo "CMD: $CMD" 1>&2
	eval "$CMD")
}
