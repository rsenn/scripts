#!/bin/bash
# 

NL="
"
IFS="${NL} "
tokcharset="_A-Za-z0-9"
tokexpr="[${tokcharset}]\\+"

while :; do
   case "$1" in
     -i | --INC) INC="${INC:+$INC$NL}$2"; shift 2 ;;
     -i=* | --INC=*) INC="${INC:+$INC$NL}${1#*=}"; shift ;;
     -x | --EXC) EXC="${EXC:+$EXC$NL}$2"; shift 2 ;;
     -x=* | --EXC=*) EXC="${EXC:+$EXC$NL}${1#*=}"; shift ;;
     -u | --uniq) UNIQ=true; shift ;;
     *) break ;;
   esac
done

FILTER="\\|^\$|d"
SED_ARGS=""

if ["$EXC" ]; then
  for X in $EXC; do
    FILTER="${FILTER}${NL}\\|$X|d"
  done
fi

if [ "$INC" ]; then
  for I in $INC; do
    FILTER="${FILTER}${NL}\\|$I|p"
  done
  SED_ARGS="-n"
fi

CMD="sed \"s|[^\${tokcharset}]|\\\\n|g\" \"\$@\" | sed \$SED_ARGS \"\$FILTER\""

[ "$UNIQ" = true ] && CMD="$CMD | uniq"

eval "$CMD"