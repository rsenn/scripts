pathmunge()
{
  while :; do
    case "$1" in
      -s) PATHSEP="$2"; shift 2 ;;
      -v) PATHVAR="$2"; shift 2 ;;
      -e) EXPORT="export "; shift ;;
      -f) FORCE=true; shift ;;
      -a) AFTER=true; shift ;;
      *) break ;;
    esac
  done
  [ "$FORCE" = true ] && pathremove "$1"
  local IFS=":";
  : ${OS=`uname -o | head -n1`};
  case "$OS:$1" in
      [Mm]sys:*[:\\]*)
          tmp="$1";
          shift;
          set -- `${PATHTOOL:-msyspath} "$tmp"` "$@"
      ;;
  esac;
  if ! eval "echo \"\${${PATHVAR-PATH}}\"" | grep -E -q "(^|${PATHSEP-:})$1($|${PATHSEP-:})"; then
      if [ "$2" = after -o "$AFTER" = true ]; then
          eval "${EXPORT}${PATHVAR-PATH}=\"\${${PATHVAR-PATH}:+\$${PATHVAR-PATH}${PATHSEP-:}}\$1\"";
      else
          eval "${EXPORT}${PATHVAR-PATH}=\"\$1\${${PATHVAR-PATH}:+${PATHSEP-:}\$${PATHVAR-PATH}}\"";
      fi;
  fi
  unset PATHVAR
}
