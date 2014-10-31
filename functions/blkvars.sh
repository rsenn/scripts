blkvars()
{
  CMD=$(IFS=" "; set -- `blkid "$1"`; shift; echo "$*")
	shift
	if [ $# -gt 0 ]; then
		for V; do
			CMD="$CMD; echo \"\${$V}\""
		done
		CMD="($CMD)"
	fi
	eval "$CMD"
}
