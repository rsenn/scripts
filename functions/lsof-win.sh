lsof-win()
{
#  (for PID in $(ps -aW | sed 1d |awkp 1); do
#    handle -p "$PID" |sed "1d;2d;3d;4d;5d; s|^|$PID\\t|"
#  done)
 (while :; do
    case "$1" in
      -p) PIDS="${PIDS+$PIDS$IFS}$2"; shift 2 ;;
      -p=*) PIDS="${PIDS+$PIDS$IFS}${1#*=}"; shift ;;
      -p*) PIDS="${PIDS+$PIDS$IFS}${1#-p}"; shift ;;
      *) break ;;
    esac
  done
  if [ -n "$PIDS" ]; then
    CMD='for PID in $PIDS; do EXE=$(proc-by-pid $PID); echo "${EXE##*[\\/]}.exe pid: $PID"; handle -p $PID; done'
  else
    CMD='handle -a'
  fi
  eval "$CMD" 2>&1 | { 
  TAB="	"
  CR=""
  IFS="$CR"
  while read -r LINE; do
    case "$LINE" in
      *"pid: "*) 
        LSOF_PID=${LINE##*"pid: "}
        LSOF_PID=${LSOF_PID%%" "*}
        EXE=${LINE%%" "*}
        EXE=${EXE%.[Ee][Xx][Ee]}
      ;;
      "" | "Copyright (C) 1997-2014 Mark Russinovich" | "Handle v4.0" | "Sysinternals - www.sysinternals.com") continue ;;

      *) printf "%-10s %5d %s\n" "$EXE" "$LSOF_PID" "$LINE" ;;
    esac
  done; }) |sed -u 's,\\,/,g'
}
