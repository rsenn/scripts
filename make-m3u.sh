#!/bin/bash

IFS="
"
main()
{
	while :; do
		case "$1" in
			--) shift; break ;;
			-h | --help) usage; exit 0 ;;
			-x | --debug) DEBUG=true ;;
			*) break ;;
		esac
		shift
	done
	set -f

	echo "#EXTM3U"
	for ARG; do
		  D=$(duration "$ARG")
			TITLE=${ARG##*/}
			TITLE=${TITLE%.*}
			TITLE=${TITLE//"_"/" "}
			TITLE=${TITLE//" - "/"-"}
			TITLE=$(echo "$TITLE" | sed 's|[^[:alnum:]][0-9]\+p[^[:alnum:]]| |g ;; s|\[| |g ;;  s|\]| |g ;; s|[ _]\+| |g ;')
			RESOLUTION=$(resolution "$ARG")
			BITRATE=$(bitrate "$ARG")
	    echo "#EXTINF:$D,${TITLE}${RESOLUTION:+ [$RESOLUTION]}${BITRATE:+ ${BITRATE}kbps}"
			echo "$ARG"
  done
}

duration()
{
    ( IFS=" $IFS";
      CMD='echo "${ARG:+$ARG:}$S"'
    while :; do
       case "$1" in
         -m | --minute*) CMD='echo "${ARG:+$ARG:}$((S / 60))"' ; shift ;;
       *) break ;;
     esac
   done
    N="$#";
    for ARG in "$@"
    do
        D=$(mminfo "$ARG" |sed -n 's,Duration=,,p' | head -n1);
        set -- $D;
        S=0;
        for PART in "$@";
        do
            case $PART in
                *ms)
                    S=$(( (S * 1000 + ${PART%ms}) / 1000))
                ;;
                *mn)
                    PART=${PART%%[!0-9]*};
                    S=$((S + $PART * 60))
                ;;
                *h)
                    S=$((S + ${PART%h} * 3600))
                ;;
                *s)
                    S=$((S + ${PART%s}))
                ;;
            esac;
        done;
        [ "$N" -gt 1 ] && eval "$CMD" || ARG= eval "$CMD"
    done )
}

mminfo()
{
    ( for ARG in "$@";
    do
        minfo "$ARG" | sed -n "s,^\([^:]*\):\s*\(.*\),${2:+$ARG:}\1=\2,p";
    done | sed 's,\s\+=,=,')
}

minfo()
{
    #timeout ${TIMEOUT:-10} \
   (CMD='mediainfo "$ARG" 2>&1'
    [ $# -gt 1 ] && CMD="$CMD | addprefix \"\$ARG:\""
    CMD="for ARG; do $CMD; done"
    eval "$CMD")  | sed '#s|\s\+:\s\+|: | ; s|\s\+:\([^:]*\)$|:\1| ; s| pixels$|| ; s|: *\([0-9]\+\) \([0-9]\+\)|: \1\2|g '
}

resolution()
{  
  (minfo "$@"|sed -n "/Width\s*: / { N; /Height\s*:/ { s,Width\s*:,, ; s,[^:\n0-9]\+: \+\([^:]*\)\$,\1,g; s|^\s*||; s|\([0-9]\)\s\+\([0-9]\)|\1\2|g; s|\s*pixels||g;  s|\n|x|g; p } }")
}

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
		#echo "BR: $*" 1>&2
   #echo "$*" 1>&2
    for I in "${@##*:}"; do R=` expr $R + ${I##*=}` ; done 2>/dev/null
	 #R=${*##*:}
   [ "$N" -gt 1 ] && R="$ARG:$R"
      echo "$R"
      )
  done )
}
main "$@"
