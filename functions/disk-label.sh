disk-label() {
 (LABEL=`volname "$1"`
  if [ -n "$1" -a -e "$1" -a -n "$LABEL" ]; then
    echo "$LABEL"
    exit 0
  fi      
  ESCAPE_ARGS="-e"
  while :; do
    case "$1" in
      -E | --no-escape) ESCAPE_ARGS=; shift ;;
      *) break ;;
    esac
  done
  DEV=${1}
  test -L "$DEV" && DEV=` myrealpath "$DEV"`
  cd /dev/disk/by-label
  find . -type l | while read -r LINK; do
    TARGET=`readlink "$LINK"`
    if [ "${DEV##*/}" = "${TARGET##*/}" ]; then
      NAME=${LINK##*/}
      NAME=${NAME//'\x20'/'\040'}
      case "$NAME" in
        *[[:lower:]]*) LOWER=true ;;
      esac
      if [ "$LOWER" = true -o ! -r "$LINK" ]; then
        echo $ESCAPE_ARGS "$NAME"
      else
        FS=` filesystem-for-device "$DEV"`
        case "$FS" in
          *fat)
              IFS="
"
            set -- $(dosfslabel "$LINK")
            test $# = 1 && echo "$1"
          ;;
          *) echo $ESCAPE_ARGS "$NAME" ;;
        esac
      fi
      exit 0
    fi
  done
  exit 1)
}
