yaourt-search() { 
(NPAD=32; VPAD=24; : ${COLS=$(tput cols)}; while :; do
   case "$1" in
		-*) pushv OPTS "$1"; shift ;;
		*) break ;;
		esac
	done
 
 CMD="yaourt-search-cmd | yaourt-search-output"
 eval "$CMD"
 )
}
	yaourt-search-cmd() {
  for Q in "$@"; do
	 (IFS="| $IFS"; set -- $Q
   command yaourt -Ss $@ | yaourt-joinlines -s "|" $OPTS | 
   command grep -a --line-buffered --colour=auto -i -E "($*)")
 done; }
 yaourt-search-output() {
	 IFS=" "; while read -r NAME VERSION_DESC; do
	 DESC=${VERSION_DESC##*"|"}
	 VERSION=${VERSION_DESC%%"|"*}
	 NUM="(${VERSION#*"("}"
	 VERSION=${VERSION%"$NUM"}
	 VERSION=${VERSION%" "}
(
	N=$(printf "%-${NPAD}s" "${NAME}"  )
	[ ${#N} -gt $((NPAD)) ] && VPAD=$((VPAD - (  ${#N}  -    $((NPAD)) ) ))

	V=$(printf "%-${VPAD}s"  "${VERSION}" )
 #MAXDESC=$(( COLS - (NPAD + 1 + VPAD + 1) )) 
 MAXDESC=$(( COLS - ${#N} - 1 - ${#V} - 1 ))
	 if [ ${#DESC} -gt $(( COLS - ${#N} - 1 - ${#V} - 1))  ]; then
		 DESC=${DESC:1:$((MAXDESC-3))}...
	fi
	echo "$N $V $DESC"
	)
 done
}
