git-get-remote() {
 (while :; do
 		case "$1" in
			-l | --list) LIST=true; shift ;;
		  -n | --name) NAME=$2; shift 2 ;; -n=* | --name=*) NAME=${1#*=}; shift ;; 
			*) break ;;
		esac
	done
	[ $# -lt 1 ] && set -- .
  [ $# -gt 1 ] && FILTER="sed \"s|^|\$DIR: |\"" || FILTER=

	EXPR="s|\\s\\+| |g"
	if [ -n "$NAME" ]; then
		EXPR="$EXPR ;; \\|^$NAME\s|!d"
	fi
	if [ "$LIST" = true ]; then
		EXPR="$EXPR ;; s| .*||"
	else
		EXPR="$EXPR ;; s|\\s*([^)]*)||"
	fi
  CMD="REMOTE=\`git remote -v 2>/dev/null"
	CMD="$CMD | sed \"$EXPR\""
	CMD="$CMD |uniq ${FILTER:+|$FILTER}\`;"
  CMD=$CMD'echo "$REMOTE"'
  for DIR; do
					(cd "${DIR%/.git}" >/dev/null &&	eval "$CMD")
		done)

}
