icacls-r() {
 (while :; do
    case "$1" in
      -o | --own*) TAKEOWN="true"; shift ;;
      -c | --cmd) CMD="true"; shift ;;
      -p | --print) PRINT="true"; shift ;;
      *) break ;;
    esac
  done
  if [ "$CMD" = true ]; then
    SEP=" &"
    NUL="nul"
  fi
  for ARG; do
   (
    [ -d "$ARG" ] && D="/R /D Y "
    ARG="\"\$(${PATHTOOL:-echo}${PATHTOOL:+ -aw} '$ARG')\""
    EXEC="icacls $ARG /Q /C /T /RESET"
    [ "$TAKEOWN" = true ] && EXEC="takeown ${D}/F $ARG >${NUL:-/dev/null}${SEP:-; } $EXEC"
#    [ "$CMD" = true ] && EXEC="cmd /c \"${EXEC//\"/\\\"}\""
    [ "$PRINT" = true ] && { EXEC=${EXEC//\\\"/\\\\\"}; EXEC="echo \"${EXEC//\"/\\\"}\""; }
    [ "$DEBUG" = true ] && echo "+ $EXEC" 1>&2
    ${E:-eval} "$EXEC")
  done)
}
