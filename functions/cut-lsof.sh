cut-lsof() {
 (IFS=" "
  [ $# -le 0 ] && set NAME
  CMD=
  is_num() { for N; do test "$N" -ge 0 2>/dev/null || return $?; done; }
  
  for FIELD; do CMD="${CMD:+$CMD }\${$FIELD}"; done
  CMD="echo \"$CMD\""
  eval "print() { $CMD; }"
  set -- COMMAND PID USER FD TYPE DEVICE SIZE NODE NAME
  LINE=1
  while read -r "$@"; do
    if [ "$LINE" -le 2 ]; then
      case "$TYPE" in
        TTY) set -- PID PARENT PGID WINPID TTY USERID STIME NAME; unset SIZE; LINE=$((LINE+1)); continue ;;
        "("*")") set -- COMMAND PID FD TYPE MODE NAME ;;
         *)
					if is_num "$COMMAND" "$PID" "$USER" "$FD" || [ "$COMMAND" = I ]; then
					  set -- PID PARENT PGID WINPID TTY USERID STIME NAME
					elif (! is_num "$NODE" || [ -z "$NAME" ]); then
						NAME="$NODE${NAME:+ $NAME}"; unset NODE
						set -- COMMAND PID USER FD TYPE DEVICE SIZE NAME
					fi
					
				  ;;
			esac
		fi
		case "$PID" in
		  I) PID="$PARENT" PARENT="$PGID" PGID="$WINPID" WINPID="$TTY" TTY="$USERID" USERID="$STIME" STIME="${NAME%% *}" NAME="${NAME#* }" ;;
		esac
		case "${SIZE:-$STIME}" in
		  Jan | Feb | Mar | Apr | May | Jun | Jul | Aug | Sep | Oct | Dec)
		    NAME=${NAME#*" "}
		  ;;
		esac
		NAME=${NAME#[0-2][0-9]:[0-5][0-9]:[0-5][0-9]" "}
    print
    LINE=$((LINE + 1))
  done)
}
