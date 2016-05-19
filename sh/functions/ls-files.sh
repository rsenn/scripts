ls-files()
{
    ( [ -z "$@" ] && set -- .;
		while :; do 
			case "$1" in
			 -*) OPTS="${OPTS:+$OPTS
}$1"; shift ;;
      *) break ;;
		esac
	done
    for ARG in "$@";
    do
        ls --color=auto -d $OPTS -- "$ARG"/*;
    done ) | filter-test -f| ${SED-sed} 's,^\./,,; s,/$,,'
}
