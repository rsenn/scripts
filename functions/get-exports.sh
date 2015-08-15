get-exports() {
 (N=$#
  [ "$N" -gt 1 ] && PREFIX='$ARG: ' || PREFIX=''
  CMD='dumpbin -exports "$ARG" |sed -n "/^\\s*ordinal\\s\\+name/ { n; :lp; n; s|^\\s*[0-9]*\\s\\+\\(.*\\)|'$PREFIX'\\1|p; /^\\s*\$/! b lp; }"'
  for ARG; do
    eval "$CMD"
  done)
}
