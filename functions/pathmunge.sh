pathmunge()
{
  while :; do
    case "$1" in
      -v) PATHVAR="$2"; shift 2 ;;
      *) break ;;
    esac
  done
  : ${PATHVAR="PATH"}
  local IFS=":";
  : ${OS=`uname -o`};
  case "$OS:$1" in
      [Mm]sys:*[:\\]*)
          tmp="$1";
          shift;
          set -- `${PATHTOOL:-msyspath} "$tmp"` "$@"
      ;;
  esac;
  if ! eval "echo \"\${$PATHVAR}\"" | egrep -q "(^|:)$1($|:)"; then
      if test "$2" = "after"; then
          eval "$PATHVAR=\"\${$PATHVAR}:\$1\"";
      else
          eval "$PATHVAR=\"\$1:\${$PATHVAR}\"";
      fi;
  fi
}
