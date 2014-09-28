launch-x11() {
 (IFS=" "
  CMD="$*"

  : ${DISPLAY:=":0"}

  export DISPLAY
  xhost +

  eval "$CMD" 2>/dev/null >/dev/null &)
}
