explore()
{
 (r=`realpath "$1" 2>/dev/null`; [ "$r" ] || r=$1
  r=${r%/.}
  r=${r#./}
  p=`$PATHTOOL -w "$r"`
  set -x
  "${SystemRoot:+$SystemRoot\\}explorer.exe" "/n,/e,$p"
 )
}
