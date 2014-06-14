srate()
{
  ( N=$#
  for ARG in "$@";
  do
    EXPR=":\\s.*\s\\([0-9]\\+\\)\\s*\\([A-Za-z]*\\)Hz.*,"
    test $N -le 1 && EXPR=".*$EXPR" || EXPR="$EXPR:"
    EXPR="s,$EXPR\\1\\2,p"

    SRATE=$(file "$ARG" |sed -n "$EXPR" |sed 's,[Kk]$,000,')
    #echo "EXPR='$EXPR'" 1>&2

    test -n "$SRATE" && echo "$SRATE" || (
      #mminfo "$ARG" | sed -n "/Sampling rate[^=]*=/ { s,Hz,,; s,[Kk],000, ; s,\.[0-9]*\$,, ; s|^|$ARG:|; p }" | tail -n1
      SRATE=$(mminfo "$ARG" | sed -n "/Sampling rate[^=]*=/ { s,.*[:=],,; s,Hz,,; s,\.[0-9]*\$,, ; s|^|$ARG:|;  p }" | tail -n1)
      SRATE=${SRATE##*:}
      case "$SRATE" in
          *[Kk])
             CMD='SRATE=$(echo "'${SRATE%[Kk]}' * 1000" | bc -l); SRATE=${SRATE%.*}'
             #echo "$CMD" 1>&2
             eval "$CMD"
          ;;
       esac
      [ "$N" -gt 1 ]  && SRATE="$ARG:$SRATE"
      echo "$SRATE"


      )
  done )
}
