icacls-r() {
 (while :; do
    case "$1" in
      -o | --own*) TAKEOWN="true"; shift ;;
      -c | --cmd) CMD="true"; shift ;;
      *) break ;;
    esac
  done
  for ARG; do
   (ARG="\"\$(${PATHTOOL:-echo}${PATHTOOL:+ -w} '$ARG')\""
    EXEC="icacls $ARG /Q /C /T /RESET"
    [ "$TAKEOWN" = true ] && EXEC="takeown /R /D Y /F $ARG >nul & $EXEC"
    [ "$CMD" = true ] && EXEC="cmd /C \"$EXEC\""
    [ "$DEBUG" = true ] && echo "+ $EXEC" 1>&2
    eval "$EXEC")
  done)
}