explode_1() {
 (old_IFS="$IFS"; IFS="$1"; shift; set -- $*; IFS="$old_IFS"; echo "$*")
}
explode() {
 [ ${#1} -le 1 -a $# -gt 1 ] && explode_1 "$@" || (S="$1"; shift; IFS="
"; [ $# -gt 0 ] && exec <<<"$*"
  ${SED-sed} "s|${S//\"/\\\"}|\n|g")
}
