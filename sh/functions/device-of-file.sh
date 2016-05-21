device-of-file() {
 (for ARG in "$@"; do
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
     DEV=`(${GREP-grep -a --line-buffered --color=auto} -E "^[^ ]*\s+$ARG\s" /proc/mounts ;  df "$ARG" |${SED-sed} '1d' )|awkp 1|head -n1`
     [ $# -gt 1 ] && DEV="$ARG: $DEV"

     [ "$DEV" = rootfs -o "$DEV" = /dev/root ] && DEV=`get-rootfs`

     echo "$DEV"
  fi)
  done)
}