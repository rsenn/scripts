installpkg() {
 (: ${PKGDIR="$PWD"}
  for ARG; do
     case "$ARG" in
       *://*) (cd "$PKGDIR"; wget -c "$ARG"); ARG="$PKGDIR/${ARG##*/}" ;;
     esac
     command installpkg "$ARG"
  done)
}
