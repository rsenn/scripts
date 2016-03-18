yaourt-search() { 
(while :; do
   case "$1" in
		-*) pushv OPTS "$1"; shift ;;
		*) break ;;
	esac
  for Q in "$@"; do
	 (IFS="| $IFS"; set -- $Q
   command yaourt -Ss $@ | yaourt-joinlines -s "|" $OPTS | 
   command grep -a --line-buffered --colour=auto -i -E "($*)")
  done)
}
