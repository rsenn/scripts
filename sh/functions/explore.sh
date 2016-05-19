explore() {
 (r=`realpath "$1" 2>/dev/null`; [ "$r" ] || r=$1
  case "$r" in
    */*) ;;
    *) r=$PWD/$r ;;
  esac
  r=${r%/.}
  r=${r#./}
  bs="\\"
  fs="/"
  p=`$PATHTOOL -w "$r"`
  set -x
  "${SystemRoot:+$SystemRoot\\}cmd.exe" /c "explorer.exe /e,/root,${p//$bs/$fs}")
}
