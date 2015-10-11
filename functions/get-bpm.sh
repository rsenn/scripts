get-bpm() {
  while :; do
    case "$1" in
      -i | --int*) INTEGER=true; shift ;;
      *) break ;;
    esac
  done
  [ $# -gt 1 ] && PFX="\$1: " || PFX=
  [ "$INTEGER" = true ] && DOT= || DOT="."
    CMD="sed -n \"/TBPM/ { s|.*TBPM\\x00\\x00\\x00\\x07\\x00*|| ;; s,[^${DOT}0-9].*,, ;; s|^|$PFX| ;;  p }\" \"\$1\""
  while [ $# -gt 0 ]; do
    #echo "+ $CMD" 1>&2
    eval "$CMD"
    shift
  done
}
