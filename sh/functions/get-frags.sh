get-frags() {
 (while :; do
    case "$1" in
      -l | --left) LEFT=true; shift ;;
      -x | --debug) DEBUG=true; shift ;;
      *) break ;;
    esac
  done
  FS="/" BS="\\"
  EXPR="s/.*Average frag.*:\s\+\([0-9]\+\)\s\+.*/\1/"
  if [ $# -gt 1 ]; then
    "${LEFT:-false}" &&
    EXPR="$EXPR ;; s/\$/${SEP:- }\${ARG//\$FS/\$BS\$FS}/" ||
    EXPR="$EXPR ;; s/^/\${ARG//\$FS/\$BS\$FS}${SEP:-: }/"
  fi
  EXPR="/Average frag/ { $EXPR; p }"
  CMD='contig -a "$ARG" | ${SED-sed} -n "'$EXPR'"'
  CMD="($CMD) || return \$?"
  "${DEBUG:-false}" && echo 1>&2 "CMD='$CMD'"
  eval "for ARG; do
   $CMD
  done")
}
