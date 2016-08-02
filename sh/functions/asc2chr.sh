asc2chr()
{
	(while :; do
	   case "$1" in
			   -n|-nonewline|--nonewline) NONL="-nonewline"; shift ;;
				 *) break ;;
			esac
		done
    CMD='echo "puts ${NONL:+$NONL }[format \"%c\" $ASC]"'
		CMD="for ASC; do $CMD; done | tclsh"
		eval "$CMD")
}
