#!/bin/bash
MYKEY=`basename "${0%.sh}"`
NL="
"
BS="\\"
  
UNICODE_CHARSET="UTF-16LE"
#UNICODE_CHARSET="WINDOWS-1252"
BYTE_CHARSET="UTF-8"
#BYTE_CHARSET="CP850"

#OUTPUT_CHARSET="WINDOWS-1252"
  
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
 (case "$#":"$2" in
		1:*) set reg query "$1" ;;
		2:"") set reg query "$1" /ve ;;
		2:*) set reg query "$1" /v "$2" ;;
	esac
  "$@" >&/dev/null
  R=$?
  exit $R)
}

clear_state() {
  if [ "$HEADER_DONE" != "true" ]; then
    echo "$BODY"
  elif [ -n "$BODY" ] && match_KEY "$KEY"; then
   
    if [ "$LIST" = "true" ]; then
      echo "$KEY" 
    else
      case "$BODY" in
        *"$NL"*) ;;
        *) BODY= ;;
      esac
      [ -n "$BODY" ] && echo "${BODY:+
$BODY}"
    fi
  fi

  KEY= VALUE= START_LINE=  BODY=
  
  EXCLUDE_KEY="false"
  EXCLUDE_VALUE="false"
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
			
			KEY=${LINE#"["}; KEY=${KEY%"]"} 
			START_LINE="$LINENO"

			;;
	esac
	
	case "$LINE" in
		"["*"]") 
			KEY=${LINE#"["}
			KEY=${KEY%"]"}
							
			if exclude_keys "$KEY"; then
				EXCLUDE_KEY="true"
			elif [ "$CHECK_VALUES" != "true" ] &&
			    (([ "$EXISTING" = "exclude" ] && reg_key_exists "$KEY") ||
					 ([ "$EXISTING" = "include" ] && ! reg_key_exists "$KEY")) ; then
				EXCLUDE_KEY="true"
			else				
				EXCLUDE_KEY="false"	
			fi
				
			if [ "$EXCLUDE_KEY" = "true" ]; then
				msg "Excluding key $KEY"
			fi
				
#        if [ "$HEADER_DONE" != "true" ]; then
#          set -- $LINE; shift; push KEYS "$KEY"  
#        fi
		;;
  esac
  
  if [ -n "$KEY" ]; then
		case "$LINE" in
			\"*\"=*)
				VALUE=${LINE%%=*}
				VALUE=${VALUE#'"'}
				VALUE=${VALUE%'"'}
				
				if [ "$CHECK_VALUES" = "true" ]; then
				
				  if ([ "$EXISTING" = "exclude" ] && reg_key_exists "$KEY" "$VALUE") ||
					   ([ "$EXISTING" = "include" ] && ! reg_key_exists "$KEY" "$VALUE"); then
						EXCLUDE_VALUE="true"
					else				
						EXCLUDE_VALUE="false"
					fi
					
									
					if [ "$EXCLUDE_VALUE" = "true" ]; then
						msg "Excluding value $KEY \"$VALUE\""
					fi
			  fi
			;;
		esac
  fi
	
	if  [ "${EXCLUDE_KEY:-false}" = "true" -o "${EXCLUDE_VALUE:-false}" = "true" ]; then
		continue
	fi
	
	push BODY "$LINE"  
}


main() {
  NPARAM=0
  while :; do
    case "$1" in
      -x | --debug) DEBUG="true"; shift ;;
      -o | --output) OUTPUT="$2"; shift 2 ;; -o=* | --output=*) OUTPUT="${1#*=}"; shift ;; -o*) OUTPUT="${1#-?}"; shift ;;
      -i | --input) INPUT="$2"; shift 2 ;; -i=* | --input=*) INPUT="${1#*=}"; shift ;; -i*) INPUT="${1#-?}"; shift ;;
      -l | --list) LIST="true"; shift ;;
      -v | --values) CHECK_VALUES="true"; shift ;;
      -I | --include-exist*) EXISTING="include"; shift ;;
      -E | --exclude-exist*) EXISTING="exclude"; shift ;;
      -[xX]=* | --exclude-layer=*) push EXCLUDE_KEYS="${1#*=}"; shift ;;
      -[xX] | --exclude-layer) push EXCLUDE_KEYS="$2"; shift 2 ;;
      -[xX]*) push EXCLUDE_KEYS "${1#-?}"; shift ;;
      *) 
         case "$NPARAM" in
           0) INPUT="$1"; : $((NPARAM++)); shift ;;
           1) OUTPUT="$1"; : $((NPARAM++)); shift ;;
           *) break ;;
         esac
         ;;
    esac
     [ $# -lt 1 ] && break
  done

  if [ -n "$INPUT" ]; then
    exec <"$INPUT"
    msg "Reading from '$INPUT' ..."
  fi

  if [ -n "$OUTPUT" ]; then
    exec >"$OUTPUT"
    msg "Writing to '$OUTPUT' ..."
  fi

  create_match_function "match_KEY" "$@"
  create_match_function "exclude_keys" ${EXCLUDE_KEYS:-"----"}

  HEADER_DONE="false"
  LINENO=0

  
  PROCESS_CMD="while getline LINE; do for_each_line; done"
  PROCESS_CMD="iconv -f $UNICODE_CHARSET -t $BYTE_CHARSET | ${PROCESS_CMD}"
# PROCESS_CMD="${PROCESS_CMD} | iconv -f $BYTE_CHARSET -t $UNICODE_CHARSET"
  PROCESS_CMD="${PROCESS_CMD} | ${SED-sed} -u '1 { s/.*Windows Registry Editor.*/REGEDIT4/  ;; }'"
  
  
  eval "${PROCESS_CMD}"
}
    
main "$@"
