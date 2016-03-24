yaourt-search() { 
(NPAD=32; VPAD=24; : ${COLS=$(tput cols)}; while :; do
   case "$1" in
		 -D | --no*desc*) EVARS='$N $V'; shift ;;
		 -N | --name-only) EVARS='$N'; shift ;;
		-*) pushv OPTS "$1"; shift ;;
		*) break ;;
		esac
	done
 
 CMD="yaourt-search-cmd \"\${@//[![:alnum:]]/}\" | yaourt-search-output"
 if is-a-tty ; then
	 CMD="$CMD | grep -E --color=yes \"$(grep-e-expr "$@")\""
	else
		 NPAD= VPAD=
 fi
 eval "$CMD")
}

yaourt-search-cmd() {
  for Q in "$@"; do
	 (IFS="| $IFS"; set -- $Q
   command yaourt -Ss $@ | yaourt-joinlines -s "|" $OPTS | 
   command grep -a --line-buffered --colour=auto -i -E "($*)")
 done
}

yaourt-search-output() {
  : ${EVARS='$N $V $DESC'}
	IFS=" "
	while read -r NAME VERSION_DESC; do
    DESC=${VERSION_DESC##*"|"}
    VERSION=${VERSION_DESC%%"|"*}
    NUM="(${VERSION#*"("}"
    VERSION=${VERSION%"$NUM"}
    VERSION=${VERSION%" "}

   (N=$(printf "%${NPAD+-$NPAD}s" "${NAME}"  )
    [ $((NPAD)) -gt 0 -a ${#N} -gt $((NPAD)) ] && VPAD=$((VPAD - (  ${#N}  -    $((NPAD)) ) ))
    
    V=$(printf "%${VPAD+-$VPAD}s"  "${VERSION}" )
    #MAXDESC=$(( COLS - (NPAD + 1 + VPAD + 1) )) 
    MAXDESC=$(( COLS - ${#N} - 1 - ${#V} - 1 ))
    if [ ${#DESC} -gt $(( COLS - ${#N} - 1 - ${#V} - 1))  ]; then
			DESC=${DESC:1:$((MAXDESC-3))}...
    fi
    eval "echo \"$EVARS\"")
	done
}
