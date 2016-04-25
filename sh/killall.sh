#!/bin/bash
NL="
"

usage() {
  echo "Usage: ${0##*/} [OPTIONS] <PATTERNS...>
  
  -x, --debug  Show debug messages
" 1>&2
}

while :; do
	case "$1" in
	   -x) DEBUG=true; shift ;;
		 -*) KILLARGS="${KILLARGS+$KILLARGS
}$1"; shift ;;
	 *) break ;;
	esac
done

IFS=$' \t\r\n'

#if [ -n "$SYSTEMROOT" -a -d "$SYSTEMROOT" ]; then
#	BS='\' FS='/'
#  SYSTEMROOT="${SYSTEMROOT//"$BS"/$FS}"
#  SYSTEMDRIVE=${SYSTEMROOT%%:*}
#  SYSTEMDIR=${SYSTEMROOT#?:}
#  SYSTEMROOT=`ls -d -- /???drive/$SYSTEMDRIVE/"$SYSTEMDIR" 2>/dev/null`  
#  #echo "$SYSTEMROOT" 1>&2
#fi
#
#for DIR in "$SYSTEMROOT"/{System32,SysWOW64}; do
#  PATH="$PATH:$DIR:$DIR/wbem"
#done

: ${OS=`uname -o 2>/dev/null || uname -s 2>/dev/null`}
SED=${SED-sed}

if [ "$OS" = Darwin ]; then
  PS="ps"
	PSARGS="-axw"
  PSFILTER=""
elif type tlist 2>/dev/null >/dev/null; then
  PS="tlist"
  PSARGS="-c"
  PSFILTER="2>&1 | $SED ':lp; N; \$! { b lp; } ; s,\\n\\s\\+,\\t,g'"
elif (ps --help; ps -X -Y -Z) 2>&1 | ${GREP-grep
-a
--line-buffered
--color=auto} -q '\-W'; then
  PS="ps"
  PSARGS="-aW"
elif [ -e "$SYSTEMROOT/system32/wbem/wmic" ]; then
  PS="$SYSTEMROOT/system32/wbem/wmic"
  PSARGS="process get ProcessID,CommandLine -VALUE"
  PSFILTER=' | { while read -r LINE; do
  case $LINE in
   CommandLine=*) CMDLINE="${CMDLINE:+$CMDLINE }${LINE#*=}" ;;
   ProcessId=*) echo ${LINE#*=} $CMDLINE; CMDLINE=; ;;
  esac
done; }'   
elif type ps 2>/dev/null >/dev/null; then
  PS="ps"
  if (ps --help; ps -X -Y -Z) 2>&1 | ${GREP-grep
-a
--line-buffered
--color=auto} -q '\-W'; then
    PSARGS="-aW"
  else
    PSARGS="axw"	
  fi
fi

case `uname -o 2>/dev/null || uname` in
  *Darwin*) ;;
  *Linux*) ;;
  *)
  if type kill.exe 2>/dev/null >/dev/null && (kill.exe --help 2>&1 | ${GREP-grep
-a
--line-buffered
--color=auto} -q '\-f.*win32'); then
    KILL="kill.exe"
    KILLARGS="${KILLARGS:+
}-f"
  elif type taskkill.exe 2>/dev/null >/dev/null; then
    KILL="taskkill"
    KILLARGS="-F -PID"
  fi
;;
esac
if [ $# -le 0 ]; then
  echo "No pattern given!" 1>&2
  usage
  exit 1
fi

[ "$DEBUG" = true ] && echo "+ PS=$PS PSARGS=${PSARGS:+'$PSARGS'} ${PSFILTER:+PSFILTER='$PSFILTER' }KILL=$KILL KILLARGS=${KILLARGS:+'$KILLARGS'}" 1>&2

PATTERN="$*"
case "$PATTERN" in
	 *"^"*) #PATTERN="[0-9]:[0-9][0-9]\s+${PATTERN#"^"}" ;;
	 PATTERN=${PATTERN//"^"/"[0-9]:[0-9][0-9]\s+"} ;;

esac
PATTERN=\(` set -- $PATTERN ; IFS='|';echo "$*"`\)
PSOUT=`eval "(${DEBUG:+set -x; }\"$PS\" $PSARGS) $PSFILTER"`

PSMATCH=` echo "$PSOUT" | ([ "$DEBUG" = true ] && set -x; ${GREP-grep -a --line-buffered --color=auto} -i -E "$PATTERN" ) |grep -v -E "(killall\\.sh|\\s$$\\s)"`
set -- $(echo "$PSMATCH" | $SED -n "/${0##*/}/! s,^[^0-9]*\([0-9][0-9]*\).*,\1,p")
PIDS="$*"

if [ -z "$PIDS" ]; then

 (IFS="|$IFS"; echo "No matching process ($*)" 1>&2)
  exit 2
fi
echo "$PSMATCH"

CMD="(${DEBUG:+set -x; }${KILL:-kill} \$KILLARGS \$PID)"

CMD="for PID in $PIDS; do $CMD; done"
[ "$DEBUG" = true ] && echo "+ $CMD" 1>&2
eval "$CMD"
