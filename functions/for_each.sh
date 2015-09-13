	for_each() {
	CMD=$1
	if [ "$(type -t "$CMD")" = function ]; then
	  CMD="$CMD \"\$@\""
	fi
	shift
	if [ $# -gt 0 ]; then
	  CMD='while shift; [ "$#" -gt 0 ]; do '$CMD'; done'
	else
	  CMD='while read -r LINE; do set -- $LINE; '$CMD'; done'
	fi
	[ "$DEBUG" = true ] && echo "+ $CMD" 1>&2
	eval "$CMD"
	unset CMD
}
