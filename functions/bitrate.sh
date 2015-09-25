bitrate()
{
  ( N=$#
  for ARG in "$@";
  do
    #EXPR="\\s[^:]*\\s\\+\\([0-9]\\+\\)\\s*kbps.*"
    EXPR=":\\s.*\s\\([0-9]\\+\\)\\s*kbps.*,"
    test $N -le 1 && EXPR=".*$EXPR" || EXPR="$EXPR:"
    EXPR="s,$EXPR\\1,p"

    KBPS=$(file "$ARG" |sed -n "$EXPR")
    #echo "EXPR='$EXPR'" 1>&2

    test -n "$KBPS" && echo "$KBPS" || (
    R=0
    set -- $(mminfo "$ARG"  |sed -n "/[Oo]verall [bB]it [Rr]ate\s*=/ { s,\s*Kbps\$,, ;  s|\([0-9]\)\s\+\([0-9]\)|\1\2|g ; s,\.[0-9]*\$,, ; s,^[^=]*=,,; s|^|$ARG:|; p }")
[ "$DEBUG" = true ] && echo "BR: $*" 1>&2
   #echo "$*" 1>&2
   # for I; do R=` expr $R + ${I##*=}` ; done 2>/dev/null
   R=${*##*:}
   [ "$N" -gt 1 ] && R="$ARG:$R"
      echo "$R"
      )
  done )
}
