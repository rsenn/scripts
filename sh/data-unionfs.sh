#!/bin/sh

HOMEPATH=${HOME:-"/{Users,home}/*"}
MEDIAPATH="{/,/mnt/*/}{"${HOME#/}"/,}{Documents/,}{My\ ,}"
IFS="
"
NL="
"

list_mediapath() {
 (unset CMD
  while :; do
    case "$1" in
      -b|-c|-d|-e|-f|-g|-h|-k|-L|-N|-O|-p|-r|-s) FILTER="${FILTER:+$FILTER | }filter-test $1"; shift ;;
      -m|--mixed|-M|--mode|-u|--unix|-w|--windows|-a|--absolute|-l|--long-name) PATHTOOL_OPTS="${PATHTOOL_OPTS:+PATHTOOL_OPTS }$1"; shift ;;
      -*) OPTS="${OPTS:+$OPTS }$1"; shift ;;
      --) shift; break ;;
      *) break ;;
      esac
  done
  for ARG; do ARG=${ARG//" "/"\\ "}; ARG=${ARG//"("/"\\("};  ARG=${ARG//")"/"\\)"}; 
   CMD="${CMD:+$CMD; }set -- $MEDIAPATH${ARG#/} ; IFS=\$'\\n'; ls -1 -U -d $OPTS -- \$* 2>/dev/null"; done

  [ -n "$PATHTOOL_OPTS" ] && CMD="${PATHTOOL:+$PATHTOOL ${PATHTOOL_OPTS:--m}}${PATHTOOL:-realpath} \$($CMD)"
  #CMD="for ARG; do $CMD; done"
  [ -n "$FILTER" ] &&	 CMD="($CMD) | $FILTER"
[ "$DEBUG" = true ] && echo "CMD: $CMD" 1>&2
  eval "$CMD")
}

pushv()
{
    eval "shift;$1=\"\${$1+\"\$$1\${DELIM:-\${NL}}\"}\$*\""
}


data_unionfs() {

    while [ $# -gt 0 ]; do
        case "$1" in
           -p|-print|--print) EVAL=echo;  shift ;;
           -x|-debug|--debug) DEBUG=true;  shift ;;
            *) pushv DIRS "$1"; shift ;;
        esac
    done

    DIRLIST=${DIRS%$NL*}
    MOUNTPOINT=${DIRS#$DIRLIST$NL}

    unset DIRSPEC
    set -- $(list_mediapath $DIRLIST)

    for DIR ; do
 
        [ -z "$DIRSPEC" ] && FLAG="=RW" || FLAG=
        DIRSPEC="${DIRSPEC:+$DIRSPEC:}$DIR$FLAG"
    done

    CMD="unionfs $DIRSPEC $MOUNTPOINT -o allow_root"

    ${EVAL:-eval} "$CMD"

}
data_unionfs "$@"

