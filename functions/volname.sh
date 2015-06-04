volname () { 
   ([ $# -gt 1 ] && ECHO='echo "$drive $NAME"' || ECHO='echo "$NAME"'
    for ARG; do
	  drive=$(cygpath -m "$ARG")
	  NAME=$(cmd /c "vol ${drive%%/*}" | sed -n '/Volume in drive/ s,.* is ,,p')
	  eval "$ECHO"
	done)
}