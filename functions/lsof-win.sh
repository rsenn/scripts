lsof-win()
{
#  (for PID in $(ps -aW | sed 1d |awkp 1); do
#    handle -p "$PID" |sed "1d;2d;3d;4d;5d; s|^|$PID\\t|"
#  done)
 (handle -a 2>&1 | { 
  TAB="	"
  CR=""
  IFS="$CR"
  while read -r LINE; do
    case "$LINE" in
      *"pid: "*) 
        LSOF_PID=${LINE##*"pid: "}
        LSOF_PID=${LSOF_PID%%" "*}
        EXE=${LINE%": "*}
      ;;
      *) printf "%s\t%d\t%s\n" "$EXE" "$LSOF_PID" "$LINE" ;;
    esac
  done; })
}

