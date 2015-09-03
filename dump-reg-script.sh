#!/bin/bash
MYNAME=`basename "${0%.sh}"`
NL="
"
BS="\\"
  
#UNICODE_CHARSET="UTF-16LE"
UNICODE_CHARSET="WINDOWS-1252"
#BYTE_CHARSET="UTF-8"
BYTE_CHARSET="CP850"
  
push() {
  eval 'shift;'$1'="${'$1':+$'$1'
}$*"'
}

create_match_function() {
	FN="$1() { case \"\$1\" in"
	shift
	for ARG in "${@:-"*"}"; do
		push FN "${ARG//"$BS"/"$BS$BS"}) return 0 ;;"
	done
	push FN "*) return 1 ;;
esac
}"
	msg "FN: $FN"
	eval "$FN"
}

reg_key_exists() {
 (reg query "$1" >&/dev/null
  R=$?
  exit $R)
}

clear_state() {
  if [ "$HEADER_DONE" != "true" ]; then
    echo "$BODY"
  elif [ -n "$BODY" ] && match_name "$NAME"; then
    if [ "$LIST" = "true" ]; then
      echo "$NAME" 
    else
      echo "
$BODY"
    fi
  fi

  NAME=
  START_LINE=
  BODY=
  KEY=
  EXCLUDE_KEY=false
}

msg() {
  [ "$DEBUG" = "true" ] && echo "$*" 1>&2
}

count() {
  echo $#
}

getline() {
	: $((LINENO++))
	read -r "$1"
}

for_each_line() {
	while [ "$LINE" != "${LINE%"$BS"}" ]; do
		getline NEXTLINE 
		LINE="${LINE%"$BS"} ${NEXTLINE}"
	done
		 
	case "$LINE" in
		"") clear_state ;;
		"["*"]")
			if [ "$LIST" != "true" -a "$HEADER_DONE" != "true" ]; then
			#echo "$HEADER"
			 msg "$(IFS="$NL"; count $KEYS) keys"
			fi
			HEADER_DONE="true"
			
			NAME=${LINE#"["}; NAME=${NAME%"]"} 
			START_LINE="$LINENO"

			;;
	esac
	
	case "$LINE" in
		"["*"]") 
			KEY=${LINE#"["}
			KEY=${KEY%"]"}
							
			if exclude_keys "$KEY"; then
				EXCLUDE_KEY="true"
			elif ([ "$EXISTING" = "exclude" ] && reg_key_exists "$KEY") ||
					 ([ "$EXISTING" = "include" ] && ! reg_key_exists "$KEY") ; then
				EXCLUDE_KEY="true"
			else				
				EXCLUDE_KEY=false	
			fi
				
			if [ "$EXCLUDE_KEY" = "true" ]; then
				msg "Excluding key $KEY"
			fi
				
#        if [ "$HEADER_DONE" != "true" ]; then
#          set -- $LINE; shift; push KEYS "$KEY"  
#        fi
		;;
	esac
	
	if  [ "${EXCLUDE_KEY:-false}" = "true" ]; then
		continue
	fi
	
	push BODY "$LINE"  
}


main() {
  while :; do
    case "$1" in
      -x | --debug) DEBUG="true"; shift ;;
      -l | --list) LIST="true"; shift ;;
      -e | --include-exist*) EXISTING="include"; shift ;;
      -E | --exclude-exist*) EXISTING="exclude"; shift ;;
      -[xX]=* | --exclude-layer=*) push EXCLUDE_KEYS="${1#*=}"; shift ;;
      -[xX] | --exclude-layer) push EXCLUDE_KEYS="$2"; shift 2 ;;
      -[xX]*) push EXCLUDE_KEYS "${1#-?}"; shift ;;
      *) break ;;
    esac
  done

  if [ -f "$1" ]; then
    exec <"$1"
    shift
  fi

  create_match_function "match_name" "$@"
  create_match_function "exclude_keys" ${EXCLUDE_KEYS:-"----"}

  HEADER_DONE=false
  LINENO=0

  
  PROCESS_CMD="while getline LINE; do for_each_line; done"
  PROCESS_CMD="iconv -f $UNICODE_CHARSET -t $BYTE_CHARSET | ${PROCESS_CMD}"
  PROCESS_CMD="${PROCESS_CMD} | iconv -f $BYTE_CHARSET -t $UNICODE_CHARSET"
  
  eval "${PROCESS_CMD}"
}
    
main "$@"