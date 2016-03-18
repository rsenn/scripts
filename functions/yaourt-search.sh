yaourt-search() { 
 (for Q in "$@"; do
	 (IFS="| $IFS"; set -- $Q
   command yaourt -Ss $@ | yaourt-joinlines $OPTS | 
   command grep -a --line-buffered --colour=auto -i -E "($*)")
  done)
}
