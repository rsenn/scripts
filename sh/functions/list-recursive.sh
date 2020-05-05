list-recursive() {
(NL="
";
  [ -n "$D" ] && set -- "$D"
  [ $# -le 0 ] && set -- .
  for ARG; do
    ARG="${ARG%/}"
    ARG="${ARG#./}"
   (for ENTRY in "$ARG"/*; do
      case "$ENTRY" in
       */\*) continue ;;
      esac
      F="$ENTRY"   
      F="${F#./}"
      [ -n "$TEST" ] && ! eval "test ${TEST/\$1/\$F}" && continue
      [ -d "$F" ] && echo "$F/" || echo  "$F"
      D="$F"    list-recursive 
    done)
  done)
}
