installpkg() {
 (IFS="
"
  ARGS="$*"
  set -- $(ls -d /m*/*/pmagic/pmodules{/extra,} 2>/dev/null)
  test -d "$1" && PKGDIR="$1"
  : ${PKGDIR="$PWD"}
  for ARG in $ARGS; do
     case "$ARG" in
       *://*) (cd "$PKGDIR"; wget -c "$ARG"); ARG="$PKGDIR/${ARG##*/}" ;;
     esac
     command installpkg "$ARG"
  done)
}
