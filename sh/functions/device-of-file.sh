device-of-file() {
 (while [ $# -gt 0 ]; do
    case "$1" in
      -d|--device) COL=1;  shift ;;
      -t|--type) COL=2;  shift ;;
      -s|--size) COL=3;  shift ;;
      -u|--used) COL=4;  shift ;;
      -a|--avail*) COL=5;  shift ;;
      -p|--percent) COL=6;  shift ;;
      -m|--mnt*|--mount*) COL=7 ; shift ;;
      *) break ;;
    esac
  done
  for ARG; do
  (if [ -e "$ARG" ]; then
     if [ -L "$ARG" ]; then
         ARG=`myrealpath "$ARG"`
     fi
     if [ -b "$ARG" ]; then
         echo "$ARG"
         exit 0
     fi
     if [ ! -d "$ARG" ]; then
         ARG=` dirname "$ARG" `
     fi
     DEV=`( : ${GREP-grep} -E "^[^ ]*\s+$ARG\s" /proc/mounts ;  df "$ARG" |${SED-sed} '1d' )|awkp ${COL-1}|head -n1`
     [ $# -gt 1 ] && DEV="$ARG: $DEV"

     [ "$DEV" = rootfs -o "$DEV" = /dev/root ] && DEV=`get-rootfs`

     echo "$DEV"
  fi)
  done)
}
