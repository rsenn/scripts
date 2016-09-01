choco-search()
{
 (R=1; trap 'echo "INT: $?"; exit $R' INT 
  EX=$(grep-e-expr "$@")
  IFS=" $IFS${nl}";
  while [ $# -gt 0 ] 2>/dev/null; do
   choco search -f -v $1  || break
    shift;
  done | choco-joinlines | (set -- ${GREP:-grep
--color=yes}; set -x; "$@" -i -E "$EX")
trap '' INT; exit 0)
}
