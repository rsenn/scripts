list_lib_symbols()
{
 (unset OPTS
  while :; do
    case "$1" in
        -*) OPTS="${OPTS:+$OPTS
}$1" ;;
        *) break ;;
    esac
  done
  CMD='case "$LIB" in
 *.a) ${NM-nm} -A $OPTS "$LIB" ;;
 *.so*) ${OBJDUMP-objdump} -T $OPTS "$LIB" ;;
 esac | addprefix "$LIB: "'
  if [ $# -gt 0 ]; then
    CMD="for LIB; do $CMD; done"
  else
    CMD="while read -r LIB; do $CMD; done"
  fi
  eval "$CMD")
}
