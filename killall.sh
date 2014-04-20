#!/bin/bash
while :; do
	case "$1" in
		 -*) KILLARGS="${KILLARGS+$KILLARGS
}$1"; shift ;;
	 *) break ;;
	esac
done

IFS=$' \t\r\n'

if type wmic 2>/dev/null >/dev/null; then
  PS="wmic"
  PSARGS="process get ProcessID,CommandLine -VALUE"
  PSFILTER=' | { while read -r LINE; do
  case $LINE in
   CommandLine=*) CMDLINE="${CMDLINE:+$CMDLINE }${LINE#*=}" ;;
   ProcessId=*) echo ${LINE#*=} $CMDLINE; CMDLINE=; ;;
  esac
done; }'   
elif type tlist 2>/dev/null >/dev/null; then
  PS="tlist"
  PSARGS="-c"
  PSFILTER="2>&1 | sed ':lp; N; \$! { b lp; } ; s,\\n\\s\\+,\\t,g'"
elif type ps 2>/dev/null >/dev/null; then
  PS="ps"
  if ps -X -Y -Z 2>&1 | grep -q '\-W'; then
    PSARGS="-aW"
  else
    PSARGS="axw"	
  fi
fi

if type taskkill.exe 2>/dev/null >/dev/null; then
  KILL="taskkill"
  KILLARGS="-F -PID"
elif type kill.exe 2>/dev/null >/dev/null; then
  KILL="kill.exe"
  KILLARGS="$KILLARGS
-f"
fi



PATTERN=\(`IFS='|'; echo "$*"`\)

PSOUT=`eval "$PS $PSARGS $PSFILTER"`
PSMATCH=` echo "$PSOUT" | grep -i -E "$PATTERN" `
PIDS=` echo "$PSMATCH" | sed -n "/${0##*/}/! s,^[^0-9]*\([0-9]\+\).*,\1,p"`

if [ -z "$PIDS" ]; then
  echo "No matching process ($@)" 1>&2
  exit 2
fi
echo "$PSMATCH"

for PID in $PIDS; do
  (set -x; "${KILL:-kill}" $KILLARGS $PID)
done