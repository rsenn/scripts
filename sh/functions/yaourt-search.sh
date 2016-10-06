yaourt-search() { 
(NPAD=32; VPAD=24; : ${COLS=$(tput cols)}; while :; do
   case "$1" in
		 -D | --no*desc*) EVARS='$N $V'; shift ;;
		 -N | --name-only) EVARS='$N'; shift ;;
		-*) pushv OPTS "$1"; shift ;;
		*) break ;;
		esac
	done
set -- ${@//"^"/"/"}
#set -- ${@//[.*]/" "}
#set -- ${@//\*/\.\*}
#[!\.\*[:alnum:]]/}
set -- ${@//[!.*[:alnum:]]/}
 CMD="yaourt-search-cmd"
 [ $# -gt 0 ] && CMD="$CMD \"\${@//[!.*[:alnum:]]/}\"" 
 CMD="$CMD | yaourt-search-output"
 if is-a-tty; then
     [ $# -gt 0 ] && CMD="$CMD | ${GREP-grep -a --line-buffered --color=auto} -E \"($(IFS="|"; echo "$*"))\""
	else
		 NPAD= VPAD=
 fi
 eval "$CMD")
}

yaourt-search-cmd() {
  [ $# -gt 0 ] || set -- ""
  for Q in "$@"; do
      (IFS="| $IFS"; Q=${Q//"\\\\"/"\\"}; Q=${Q//"\\."/"."}; Q=${@//"\\*"/"*"}; set -- $Q
	 ([ "$DEBUG" = true ] && set -x
${YAOURT:-${YAOURT:-command yaourt}} -Ss $@) | yaourt-joinlines -s "|" $OPTS | 
   command ${GREP-grep -a --line-buffered --color=auto}  -i -E "($*)")
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
pacman-search() { YAOURT="pacman" yaourt-search "$@"; }
