awkp() {
 (IFS="
	"; N=${1}
	CMD="awk"
	[ $# -le 0 ] && set -- 1
	SCRIPT=""

  while :; do
		case "$1" in
			-[A-Za-z]*) CMD="$CMD $1"; shift ;;
			[0-9]) SCRIPT="${SCRIPT:+$SCRIPT\" \"}\$$1"; shift ;;
			[0-9]*) SCRIPT="${SCRIPT:+$SCRIPT\" \"}\$($1)"; shift ;;
			*) break ;;
		esac
	done
	eval "$CMD \"{ print \$SCRIPT }\"")
}
