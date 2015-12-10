destdir() { 
	CCHOST=$(IFS="$IFS "; ${CC-cc} -dumpmachine);
	case "$CCHOST" in 
	*diet*)
	    PKGARCH=diet
	;;
	*linux*)
	    PKGARCH=linux
	;;
	*)
	    PKGARCH=$(IFS="$IFS -"; set -- $CCHOST; echo "${2:-$1}")
	;;
	esac;
	case "$CCHOST" in 
	i[3-6]86*)
	    PKGARCH="${PKGARCH}32"
	;;
	x86?64*)
	    PKGARCH="${PKGARCH}64"
	;;
	*)
	    PKGARCH="${CCHOST%%-*}-${PKGARCH}"
	;;
	esac;
	echo "$PWD-$PKGARCH"
}
