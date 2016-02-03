sln-version() { 
 (while :; do
    case "$1" in
      -x | --debug) DEBUG="true"; shift ;;
      -vs* | --vs*) E='$VSVER'; shift ;;
       -vc* | --vc*) E='$VCVER'; shift ;;
      -f | --file) E='$FVER'; shift ;;
      *) break ;;
    esac
  done
  : ${E='"$FVER"${VSVER:+ "$VSVER"}'}
  [ $# -gt 1 ] && E='"$ARG": '$E
  
  for ARG in "$@"; do
   (exec < "$ARG"
    read LINE
    while [ "${#LINE}" -lt 4 ]; do  read  LINE ; done # skip BOM    
    FVER=${LINE##*"Version "}
    read -r LINE
    case "$LINE" in
      *\ 20[01][0-9]\ *) LINE=${LINE%%" ${LINE##*20[01][0-9]}"*} ;;
    esac
    case "$LINE" in 
      *Version\ *) FVER=${LINE##*"Version "} ;;
      *"Visual Studio 20"[01][0-9]*) VSVER=${LINE##*Visual*"Studio "}; VSVER=${VSVER%%" "*} ;;
      *\ 20[01][0-9]) VSVER=${LINE##*" "} ;;
    esac
    case "$E" in
      *\$VCVER*) VCVER=$(vs2vc "$VSVER") ;;
    esac
    eval "echo $E")
  done)
}
