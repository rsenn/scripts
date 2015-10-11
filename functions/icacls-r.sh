icacls-r() {
 (for ARG; do
   (CMD="icacls \"$(${PATHTOOL:-echo}${PATHTOOL:+
-w} "$ARG")\" /Q /C /T /RESET"
    [ "$DEBUG" = true ] && echo "+ $CMD" 1>&2
    exec cmd /c "$CMD")
  done)
}
