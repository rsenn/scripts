multiline_list()
{ 
 (INDENT='  ' IFS="
  "
  case "$1" in
    -i) INDENT=$2 && shift 2 ;;
    -i*) INDENT=${2#-i} && shift
    ;;
    *) break ;;
  esac;
  done;
  if test -z "$*" || test "$*" = -; then
    cat
  else
    echo "$*";
  fi |
  while read ITEM; do
      echo " \\";
      echo -n "$INDENT$ITEM";
  done)
}
