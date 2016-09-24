bitrate()
{
  ( N=$#
  for ARG in "$@";
  do
    #EXPR="\\s[^:]*\\s\\+\\([0-9]\\+\\)\\s*kb[p/]s.*"
    EXPR=":\\s.*\s\\([0-9]\\+\\)\\s*kb[/p]s.*,"
    test $N -le 1 && EXPR=".*$EXPR" || EXPR="$EXPR:"
    EXPR="s,$EXPR\\1,p"

    KBPS=$(file "$ARG" |${SED-sed} -n "$EXPR")
    #echo "EXPR='$EXPR'" 1>&2

    test -n "$KBPS" && echo "$KBPS" || (
    R=0
    set -- $(mminfo "$ARG"  |${SED-sed} -n "/[Oo]verall [bB]it [Rr]ate\s*=/ { s,\s*[kK]b[p/]s\$,, ;  s|\([0-9]\)\s\+\([0-9]\)|\1\2|g ; s,\.[0-9]*\$,, ; s,^[^=]*=,,; s|^|$ARG:|; p }")
    [ "$DEBUG" = true ] && echo "BR: $*" 1>&2
   R=${*##*:}
   case "$R" in
       *Mb[/p]s | *Mb?s) R=${R%%Mb?s*}; R=${R%" "}; R=$(echo "$R * 2^10"  | bc -l ); : ${R:=$(( ${R%%.*} * 1024  )) } ;; 
       *Gb[/p]s | *Gb?s) R=${R%%Gb?s*}; R=${R%" "}; R=$(echo "$R * 2^20"  | bc -l ); : ${R:=$(( ${R%%.*} * 1024 * 1024 )) } ;; 
       *Tb[/p]s | *Tb?s) R=${R%%Tb?s*}; R=${R%" "}; R=$(echo "$R * 2^30"  | bc -l ); : ${R:=$(( ${R%%.*} * 1024 * 1024 * 1024 )) } ;;
       *Pb[/p]s | *Pb?s) R=${R%%Pb?s*}; R=${R%" "}; R=$(echo "$R * 2^40"  | bc -l ); : ${R:=$(( ${R%%.*} * 1024 * 1024 * 1024 * 1024 )) } ;;
   esac
   [ "$N" -gt 1 ] && R="$ARG:$R"
      echo "$R"
      )
  done )
}
