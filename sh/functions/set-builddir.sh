set-builddir() {
  CCPATH=$(which ${CC:-gcc})
  case "$CCPATH" in
    */mingw??/*) CCHOST=${CCPATH%%/mingw??/*}; CCHOST=${CCHOST##*/} ;;
    *) CCHOST=$("$CCPATH" -dumpmachine);	CCHOST=${CCHOST%$r} ;;
	esac
	builddir=build/$CCHOST
	mkdir -p $builddir
	echo "$builddir"
}
