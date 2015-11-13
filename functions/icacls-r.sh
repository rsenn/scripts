icacls-r() {
 (while :; do
    case "$1" in
      -o | --own*) TAKEOWN="true"; shift ;;
      -c | --cmd) CMD="true"; shift ;;
      -p | --print) PRINT="true"; shift ;;
      -s | --separator) SEP="$2"; shift 2 ;;
      *) break ;;
    esac
  done
  if [ "$CMD" = true ]; then
    : ${SEP=" & "}
    NUL="nul"
  fi
  : ${ICACLS=icacls}
  
  case "$ICACLS" in
    *icacls*) ICACLS_ARGS="/T /Q /C /RESET"  ;;
    *cacls*) ICACLS_ARGS="/T /C /G Everyone:F" ;;
    *xcacls*) ICACLS_ARGS="/T /C /Q /G Everyone:F" ;;
   esac
  for ARG; do
   (ARG=${ARG%/}
    [ -d "$ARG" ] && D="/R /D Y "
    ARG="\"\$(${PATHTOOL:-echo}${PATHTOOL:+ -aw} '$ARG')\""
    EXEC="${ICACLS:-icacls} $ARG ${ICACLS_ARGS}"
    [ "$TAKEOWN" = true ] && EXEC="takeown ${D}/F $ARG >${NUL:-/dev/null}${SEP:-; }$EXEC"
#    [ "$CMD" = true ] && EXEC="cmd /c \"${EXEC//\"/\\\"}\""
    [ "$PRINT" = true ] && { EXEC=${EXEC//\\\"/\\\\\"}; EXEC="echo \"${EXEC//\"/\\\"}\""; }
    [ "$DEBUG" = true ] && echo "+ $EXEC" 1>&2
    ${E:-eval} "$EXEC")
  done)
}
