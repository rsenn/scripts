filter-test()
{ 
  ( IFS="
  ";
  unset ARGS NEG;
  while :; do
      case "$1" in 
          -a | -b | -c | -d | -e | -f | -g | -h | -k | -L | -N | -O | -p | -r | -s | -u | -w | -x)
              ARGS="${ARGS:+$ARGS
}"${NEG:+'!
'}"$1";

              shift;
              NEG=""
          ;;
          '!')
              [ "${NEG:-false}" = false ] && NEG='!' ||
              NEG=
              shift
          ;;
          *)
              break
          ;;
      esac;
  done;
  [ -z "$ARGS" ] && { 
      exit 2
  };
  IFS=" ";
  set -- $ARGS;
  ARGN=$#;
  ARGS="$*";
  IFS="
"
  while read -r LINE; do
 set -- $LINE;
      #if [ $ARGN = 1 ]; then
          test $ARGS "$LINE" || continue 2;
      #else
      #    eval "test $ARGS \"\$LINE\"" || continue 2;
      #fi;
      echo "$LINE";
  done )
}
