#!/bin/bash
MYNAME=`basename "${0%.sh}"`

create_match_function() {

  FN="$1() { case \"\$1\" in"
  shift
  for ARG in "${@:-"*"}"; do
    push FN "$ARG) return 0 ;;"
    push FN "*\\'$ARG[.\\']*) return 0 ;;"
  done
  push FN "*) return 1 ;;
esac
}"
#  msg "FN: $FN"
  eval "$FN"
}

clear_state() {
  if [ "$HEADER_DONE" != true ]; then
  #case "$BODY" in
   # '#'*) BODY=; return 0 ;;
    #*) push HEADER "${BODY%#*}" ; BODY= ;;
#    esac
 #   push HEADER "$BODY"
  #  BODY=
    : echo "BODY$LF${BODY//$LF  /${LF}BODY }"
  elif [ -n "$BODY" ] && match_name "$NAME"; then
    if [ "$LIST" = true ]; then
      echo "$NAME" 
    else
    msg "Got body of '$NAME'."
    
    fi
  fi
  if [ "$HEADER_DONE" -a -z "$HEADER" ]; then
       HEADER=$(echo "$BODY"|sed '/^\s*#/d ; s,\s*#[^\n]*,,g ; s,\n\s*,\n,g')
  fi
  NAME=
  START_LINE=
  BODY=
  LAYER=
  EXCLUDE_LAYER=false
}

msg() {
  echo "$MYNAME: $*" 1>&2
}

count() {
  echo $#
}

dbg() {
          [ "$DEBUG" = true ] && echo "$@" 1>&2
}

output_item() {
  HEADER=${HEADER//$LF  /$LF}
  BODY=${BODY//$LF  /$LF}
  O=${NAME//"/"/"_"}.scr
   echo "$HEADER$LF$BODY" >"$O"
   msg "Wrote $O."
  #          echo "HEADER ${HEADER//$LF  /${LF}HEADER }"
}
dump_eagle_script() {
  NL="
  "
CR=''
  LF='
'
  BS="\\"

  push() {
  eval 'shift;'$1'="${'$1':+$'$1'
}$*"'
  }
  while :; do
    case "$1" in
      -x | --debug) DEBUG=true; shift ;;
      -l | --list) LIST="true"; shift ;;
      -[xX]=* | --exclude-layer=*) push EXCLUDE_LAYERS="${1#*=}"; shift ;;
      -[xX] | --exclude-layer) push EXCLUDE_LAYERS="$2"; shift 2 ;;
      -[xX]*) push EXCLUDE_LAYERS "${1#-?}"; shift ;;
      *) break ;;
    esac
  done
  if [ -f "$1" ]; then
    exec <"$1"
    shift
  fi
  create_match_function "match_name" "$@"
  create_match_function "exclude_layers" ${EXCLUDE_LAYERS:-"----"}
#  while [ $# -gt 0 ]; do
#    push MATCH_NAME "$1) return 0 ;;"
#    shift
#  done
#  : ${MATCH_NAME:="*) return 0 ;;"}

#  MATCH_NAME='match() { case "$1" in
#    '$MATCH_NAME'
#    *) return 1 ;;
#  esac; }'
#
#  msg "MATCH_NAME: $MATCH_NAME"
# eval "$MATCH_NAME"
  HEADER_DONE=false
  LINENUM=0

  getline() {
    : $((LINENUM++))
    read -r "$1"; R=$?
    eval "$1=\${$1%\"$CR\"}"
    return $R
  }
  while getline LINE; do
  LINE=${LINE%$'\r'}
#  msg "LINE: $LINE"
    while [ "$LINE" != "${LINE%"$BS"}" ]; do
      getline NEXTLINE 
      LINE="${LINE%"$BS"} ${NEXTLINE}"
    done
    case "$LINE" in
      "")
      
#      if match_name "$NAME"; then
      output_item
#      fi
      
       clear_state ;;
      "Edit '"*)
        if [ "$LIST" != true -a "$HEADER_DONE" != true ]; then
      #    echo "HEADER ${HEADER//$LF  /${LF}HEADER }"
         msg "$(IFS="$NL"; count $LAYERS) layers"
        fi
        HEADER_DONE=true
        NAME=${LINE#"Edit '"}; NAME=${NAME%%"'"*} 
        START_LINE="$LINENUM"
        if match_name "$NAME" || match_name "$LINE"; then
          MATCH_COND=true
          dbg "EDIT[$LINENUM]: $LINE"
        else
          MATCH_COND=false
        fi
        ;;
      "Layer "*) 
        set -- ${LINE%%";"*}; shift
        LAYER="$*"
#        dbg "LAYER[$LINENUM]: $LAYER"
        if exclude_layers "$LAYER"; then
          EXCLUDE_LAYER=true
        else
          EXCLUDE_LAYER=false  
        fi
        if [ "$HEADER_DONE" != true ]; then
          set -- $LINE; shift; push LAYERS "$LAYER"  
        fi
      ;;
    esac
    if  [ "${EXCLUDE_LAYER:-false}" = true ]; then
      continue
    fi
    push BODY "$LINE"  
  done 
  
  #echo "BODY ${BODY//$LF  /${LF}BODY }"
 #


}
dump_eagle_script "$@"