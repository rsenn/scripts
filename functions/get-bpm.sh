get-bpm() {
  [ $# -gt 1 ] && PFX="\$1: " || PFX=
    CMD="sed -n \"/TBPM/ { s|.*TBPM[\\x00\\x07]*|| ;; s,[^.0-9].*,, ;; s|^|$PFX| ;;  p }\" \"\$1\""
  while [ $# -gt 0 ]; do
    #echo "+ $CMD" 1>&2 
    eval "$CMD"
    shift
  done
}
