type pathmunge >/dev/null 2>/dev/null ||
pathmunge() {
  while :; do
    case "$1" in
      -v) PATHVAR="$2"; shift 2 ;;
      *) break ;;
    esac
  done
  local IFS=":";
  : ${OS=`uname -o 2>/dev/null || uname -s 2>/dev/null`}
  case "$OS:$1" in
      [Mm]sys:*[:\\]* | MSYS*:*)
          tmp="$1";
          shift;
          set -- `$PATHTOOL "$tmp"` "$@"
      ;;
  esac;
  if ! eval "echo \"\${${PATHVAR-PATH}}\"" | grep -E -q "(^|:)$1($|:)"; then
      if test "$2" = "after"; then
          eval "${PATHVAR-PATH}=\"\${${PATHVAR-PATH}}:\$1\"";
      else
          eval "${PATHVAR-PATH}=\"\$1:\${${PATHVAR-PATH}}\"";
      fi;
  fi
  unset PATHVAR
}

pathmunge /usr/local/bin
pathmunge /usr/local/sbin
