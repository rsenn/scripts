installpkg() {
 (IFS="
"
  ARGS="$*"
  if [ "${PKGDIR+set}" != set ]; then
    set -- $(ls -d /m*/*/pmagic/pmodules{/extra,} 2>/dev/null)
    test -d "$1" && PKGDIR="$1"
    : ${PKGDIR="$PWD"}
  fi
  for ARG in $ARGS; do
     case "$ARG" in
       *://*) (cd "$PKGDIR"; wget -c "$ARG"); ARG="$PKGDIR/${ARG##*/}" ;;
     esac
     command installpkg "$ARG"
  done)
}
