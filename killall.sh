#!/bin/bash
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

if type tlist 2>/dev/null >/dev/null; then
  PS="tlist"
  PSARGS="-c"
  PSFILTER="2>&1 | sed ':lp; N; \$! { b lp; } ; s,\\n\\s\\+,\\t,g'"
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
  if (ps --help; ps -X -Y -Z) 2>&1 | grep -q '\-W'; then
    PSARGS="-aW"
  else
    PSARGS="axw"	
  fi
fi

<<<<<<< HEAD
if type taskkill 2>/dev/null >/dev/null; then
  KILL="taskkill"
  KILLARGS="-F -PID"
elif type kill.exe 2>/dev/null >/dev/null; then
  KILL="kill.exe"
  KILLARGS="$KILLARGS
-f"
fi
=======
case `uname -o` in
  *Linux*) ;;
  *)
  if type taskkill.exe 2>/dev/null >/dev/null; then
    KILL="taskkill"
    KILLARGS="-F -PID"
  elif type kill.exe 2>/dev/null >/dev/null; then
    KILL="kill.exe"
    KILLARGS="$KILLARGS
  -f"
  fi
;;
esac
>>>>>>> 6a93b6e8e8f120e41631105957baa88a61fb4884



PATTERN=\(`IFS='|'; echo "$*"`\)

PSOUT=`eval "(${DEBUG:+set -x; }\"$PS\" $PSARGS) $PSFILTER"`
PSMATCH=` echo "$PSOUT" | grep -i -E "$PATTERN" `
PIDS=` echo "$PSMATCH" | sed -n "/${0##*/}/! s,^[^0-9]*\([0-9]\+\).*,\1,p"`

if [ -z "$PIDS" ]; then
  echo "No matching process ($@)" 1>&2
  exit 2
fi
echo "$PSMATCH"

for PID in $PIDS; do
  eval "(${DEBUG:+set -x; }${KILL:-kill} \$KILLARGS \$PID)"
done
