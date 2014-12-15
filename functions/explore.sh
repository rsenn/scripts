explore()
{
 (r=`realpath "$1" 2>/dev/null`; [ "$r" ] || r=$1
  r=${r%/.}
  r=${r#./}
  bs="\\"
  fs="/"
  p=`$PATHTOOL -w "$r"`
  set -x
  "${SystemRoot:+$SystemRoot\\}cmd.exe" /c "explorer.exe /n,\"${p//$bs/$fs}\""
 )
}
