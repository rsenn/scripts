pathremove() { old_IFS="$IFS"; IFS=":"; RET=1; unset NEWPATH; for DIR in $PATH; do for ARG in "$@"; do case "$DIR" in $ARG) RET=0; continue 2 ;; esac; done; NEWPATH="${NEWPATH+$NEWPATH:}$DIR"; done; PATH="$NEWPATH"; IFS="$old_IFS"; unset NEWPATH old_IFS; return $RET; }
pathmunge() { 
  if [ -e /bin/grep ]; then
     GREP=/bin/grep
  else
    GREP=/usr/bin/grep
  fi
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
    if ! eval "echo \"\${${PATHVAR}}\" | $GREP -E -q \"\$FXPR\""; then
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

#[ -z "$PATH" ] && export PATH=/bin:/usr/bin:/usr/local/bin
#pathremove /opt/local/bin

export PATH="/usr/sbin:/sbin:/usr/bin:/bin:/usr/X11/bin:/usr/X11R6/bin:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin"
