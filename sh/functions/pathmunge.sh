pathmunge() { 
  while :; do
    case "$1" in -s) PATHSEP="$2"; shift 2 ;;
		-v) PATHVAR="$2"; shift 2 ;;
		-e) EXPORT="export "; shift ;;
		-f) FORCE=true; shift ;;
		-a) AFTER=true; shift ;;
		*) break ;;
		esac
    done
    : ${PATHVAR=PATH}
    local IFS=":"
    : ${OS=`uname -o | head -n1`}
    case "$OS:$1" in
	  [Mm]sys:*[:\\]*) tmp="$1"; shift; set -- `${PATHTOOL:-msyspath} "$tmp"` "$@" ;;
    esac
    IFS=" "
    FXPR="(^|${PATHSEP-:})$1($|${PATHSEP-:})"
    if ! eval "echo \"\${${PATHVAR}}\" | ${GREP-grep} -E -q \"\$FXPR\""; then
	  if [ "$2" = after -o "$AFTER" = true ]
		then CMD="${EXPORT}${PATHVAR}=\"\${${PATHVAR}:+\$${PATHVAR}${PATHSEP-:}}\$1\""
		else CMD="${EXPORT}${PATHVAR}=\"\$1\${${PATHVAR}:+${PATHSEP-:}\$${PATHVAR}}\""
	  fi
    fi
    [ "$FORCE" = true ] && CMD="pathremove \"$1\"
    $CMD"
#    eval "CMD=\"${CMD//\""
    [ "$DEBUG" = true ] && eval "echo \"+ $CMD\" 1>&2"
    eval "$CMD"
    unset PATHVAR
 }
