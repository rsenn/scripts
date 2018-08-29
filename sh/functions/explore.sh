explore() {
 for ARG; do 
 (r=`realpath "$ARG" 2>/dev/null`; [ "$r" ] || r=$1
  case "$r" in
    */*) ;;
    *) r=$PWD/$r ;;
  esac
  r=${r%/.}
  r=${r#./}
  bs="\\"
  fs="/"
  p=`${PATHTOOL-cygpath} -w "$r"`
  set -x
  : ${SYSTEMROOT=$SystemRoot}
  "$(${PATHTOOL:-cygpath} -a "$COMSPEC")" "/c" "$SYSTEMROOT\\explorer.exe /n,/e,${p//$fs/$bs}")
  done
}
