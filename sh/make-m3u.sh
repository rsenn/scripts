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
    duration "$ARG"
    TITLE=${ARG##*/}
    TITLE=${TITLE%.*}
    TITLE=${TITLE//"_"/" "}
    TITLE=${TITLE//" - "/"-"}
    TITLE=$(echo "$TITLE" | ${SED-sed} 's|[^[:alnum:]][0-9]\+p[^[:alnum:]]| |g ;; s|\[| |g ;;  s|\]| |g ;; s|[ _]\+| |g ;')
    resolution "$ARG"
    bitrate "$ARG"
    echo "#EXTINF:$DURATION,${TITLE}${RESOLUTION:+ [$RESOLUTION]}${BITRATE:+ ${BITRATE}kbps}"
    echo "$ARG"
  done
}

resolution() {
 (EXPR='/Width/N
/pixels/ {
  s|Width=\([0-9]\+\)\s*pixels| \1|g
  s|Height=\([0-9]\+\)\s*pixels| \1|g
  s|[^\n]*:\s\+\([^\n:]*\)$|\1|
  s|\r\n|\n|g
  s| *\n *|x|p
}'; while [ $# -gt 0 ] ; do case "$1" in
    -m | --mult*) CMD="echo \$(($1 * $2))"; shift ;; 
    *) break ;;
  esac
  done
  mminfo "$@"|${SED-sed} -n "$EXPR")
}                                                                                                                                                                                                                                                                                    
minfo()
{
    #timeout ${TIMEOUT:-10} \
   (IFS="$IFS"$'\r' ; CMD='mediainfo "$ARG" 2>&1'
    [ $# -gt 1 ] && CMD="$CMD | addprefix \"\$ARG:\""
    CMD="for ARG; do $CMD; done"
    eval "$CMD")  | ${SED-sed} '#s|\s\+:\s\+|: | 
						s|\r||g; s|\s\+:\([^:]*\)$|:\1| ; s| pixels$|| ; s|: *\([0-9]\+\) \([0-9]\+\)|: \1\2|g '
}

duration()
{
  IFS=" $IFS";
  CMD='DURATION="${ARG:+$ARG:}$S"'
  while :; do
    case "$1" in
      -m | --minute*) CMD='echo "${ARG:+$ARG:}$((S / 60))"' ; shift ;;
      *) break ;;
    esac
  done
  N="$#"
  for ARG; do
    mminfo "$ARG"
    D=$(echo "$MMOUT" |${SED-sed} -n 's,Duration=,,p' | head -n1)
    set -- $D
    S=0
    for PART; do
      case $PART in
        *ms) S=$(( (S * 1000 + ${PART%ms}) / 1000)) ;;
        *mn|*m | *min)    PART=${PART%%[!0-9]*};  S=$((S + $PART * 60)) ;;
        *h) S=$((S + ${PART%h} * 3600)) ;;
        *s) S=$((S + ${PART%s})) ;;
      esac
    done
    [ "$N" -gt 1 ] && eval "$CMD" || ARG= eval "$CMD"
  done
}

bitrate()  {
  N=$#
  for ARG; do
    #EXPR="\\s[^:]*\\s\\+\\([0-9]\\+\\)\\s*kb[p/]s.*"
    EXPR=":\\s.*\s\\([0-9]\\+\\)\\s*kb[/p]s.*,"
    test $N -le 1 && EXPR=".*$EXPR" || EXPR="$EXPR:"
    EXPR="s,$EXPR\\1,p"

    KBPS=$(file "$ARG" |${SED-sed} -n "$EXPR")

    test -n "$KBPS" && echo "$KBPS" || {
      R=0
      mminfo "$ARG"
      set -- $(echo "$MMOUT" | ${SED-sed} -n "/[Oo]verall [bB]it [Rr]ate\s*=/ { s,\s*[kK]b[p/]s\$,, ;  s|\([0-9]\)\s\+\([0-9]\)|\1\2|g ; s,\.[0-9]*\$,, ; s,^[^=]*=,,; s|^|$ARG:|; p }")
      [ "$DEBUG" = true ] && echo "BR: $*" 1>&2
      R=${*##*:}
      case "$R" in
        *Mb[/p]s | *Mb?s) R=${R%%Mb?s*}; R=${R%" "}; R=$(echo "$R * 2^10"  | bc -l ); : ${R:=$(( ${R%%.*} * 1024  )) } ;; 
        *Gb[/p]s | *Gb?s) R=${R%%Gb?s*}; R=${R%" "}; R=$(echo "$R * 2^20"  | bc -l ); : ${R:=$(( ${R%%.*} * 1024 * 1024 )) } ;; 
        *Tb[/p]s | *Tb?s) R=${R%%Tb?s*}; R=${R%" "}; R=$(echo "$R * 2^30"  | bc -l ); : ${R:=$(( ${R%%.*} * 1024 * 1024 * 1024 )) } ;;
        *Pb[/p]s | *Pb?s) R=${R%%Pb?s*}; R=${R%" "}; R=$(echo "$R * 2^40"  | bc -l ); : ${R:=$(( ${R%%.*} * 1024 * 1024 * 1024 * 1024 )) } ;;
      esac
      R=${R%.*}
      [ "$N" -gt 1 ] && R="$ARG:$R"
      BITRATE="$R"
    }      
  done
}

format_args() {
  F=""
  for ARG; do F="${F:+$F }'${ARG//"'"/"\\'"}'"; done
  echo "$F"
}
  
mminfo_filter() { ${SED-sed} "s,\s\+=,=,  ;; s|\([0-9]\) \([0-9]\)|\1\2|g ;; /Duration/ {  s|\([0-9]\) min|\1min|g ;;  s|\([0-9]\) \([hdw]\)|\1\2|g ;; s|\([0-9]\) \(m\?s\)|\1\2|g ;; s|\([0-9]\+\) \([^ ]*b/s\)\$|\1\2| ;; }"; }
mminfo() {
 # [ "$DEBUG" = true ] && echo "+ mminfo $(format_args "$@")" 1>&2
  #DEBUG=false
  minfo "$1"
 MMOUT=$( echo "$LASTOUT" | ${SED-sed} -n "s,^\([^:]*\):\s*\(.*\),${2:+${1}:}\1=\2,p" | ${SED-sed} "s,\s\+=,=,  ;; s|\([0-9]\) \([0-9]\)|\1\2|g ;; /Duration/ {  s|\([0-9]\) min|\1min|g ;;  s|\([0-9]\) \([hdw]\)|\1\2|g ;; s|\([0-9]\) \(m\?s\)|\1\2|g ;; s|\([0-9]\+\) \([^ ]*b/s\)\$|\1\2| ;; }")
 
}

main "$@"
