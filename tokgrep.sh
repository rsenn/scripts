#!/usr/bin/env bash
# 
# match name token

CHARSET='0-9A-Za-z_'$EXTRACHARS
IFS="
"

unset PATTERN
unset REPLACE
unset TOKLIST
unset PREV
count=0

check_chars() {
  eval local INVAL='${'$1"%%*[!${2-$CHARSET}\$IFS]*}"
  if [ -z "$INVAL" ]; then
    echo "${0##*/}: ${3+$3 }must contain characters from [${2-$CHARSET}] only. ($INVAL)" 1>&2
    exit 1
  fi
}

subst_chars() {
  eval $1='${'$1"//$2/'$3'}"
}

num_refs() {
  local IFS="\\" REF=0 SPLIT
  set -- $PATTERN
  for SPLIT; do
    case $SPLIT in
      '('*) : $((REF++)) ;;
      ')'*) : $((REF--)) ;;
    esac
  done
  if test $REF != 0; then
    echo "${0##*/}: improperly balanced parenthesis in PATTERN" 1>&2
    exit 1
  fi
  return $(( ($# - 1) / 2 ))
}

shift_refs() {
  local IFS="\\" x=$1 OUT=$2
  set -- $REPLACE
  eval $OUT='$1'
  shift
  for SPLIT; do
    local STRIP=${SPLIT#[0-9]}
    local N=${SPLIT%"$STRIP"}
    if test -z "$N" || test "$N" -gt "$NREF"; then
      echo "${0##*/}: invalid reference near \\$SPLIT" 1>&2
      exit 1
    fi
    echo $OUT='"$'$OUT"\\"$((N+x))"$STRIP\""
    eval $OUT='"$'$OUT"\\"$((N+x))'$STRIP"'
  done
}
count() {
        echo $#
}
pushv()
{
    eval "shift;$1=\"\${$1+\"\$$1\${IFS%\"\${IFS#?}\"}\"}\$*\""
}


main() {

  OPTS=
  NTOKS=0
  MULTITOK=false
  
  for ARG; do
    [ "$DEBUG" = "true" ] && echo "ARG=\"$ARG\" NTOKS=$NTOKS" 1>&2
    [ "$ARG" = "--" ] && break
    case "$ARG" in
      -x) DEBUG=true ;;
      -*) ;;
      "--" | -- | \-\-) #MULTITOK=true;
        break  2 ;;
      *) NTOKS=$((NTOKS+1)) ;;
    esac
  done
  
  [ "$DEBUG" = "true" ] && echo "MULTITOK=$MULTITOK" 1>&2
  #if [ "${MULTITOK:-false}" = false ]; then
  #  NTOKS=1
  #fi
  
  while :; do
    case "$1" in
      -x) DEBUG=true; shift ;;
      -*) OPTS="${OPTS:+$OPTS${IFS}}$1"; shift ;;
      *) break ;;
    esac
  done
  
  if "${DEBUG:-false}"; then
    echo "@=${@:1:3} ..." 1>&2 
    echo "NTOKS=$NTOKS" 1>&2 
  fi  

  for ARG; do
    if [ "$((count++))" = 0 ]; then
      set --
    fi

    if [ -N "${PREV+set}" ]; then
      set -- "$@" "$PREV" "$ARG"
      unset PREV
      continue
    fi

    case $ARG in
    
      -x)
        DEBUG=true
        continue
      ;;
      -e|-f|-l*|-m|-d|-D|-A|-B|-C|-r*) 
        PREV=$ARG
        continue
      ;;
      
      -*) 
        set -- "$@" "$ARG" 
      ;;
      
      *)
        if [ "$(count $TOKENS)" -lt $((NTOKS)) ]; then
          pushv TOKENS "$ARG"
#          PATTERN=$ARG
#          check_chars PATTERN "$CHARSET.?*+()" PATTERN
#          subst_chars PATTERN '.' "[$CHARSET]"
#          subst_chars PATTERN '(' "\\("
#          subst_chars PATTERN ')' "\\)"
#
#          TOKLIST="${TOKLIST:+$TOKLIST|}[^$CHARSET]$PATTERN[^$CHARSET]|[^$CHARSET]$PATTERN\$|^$PATTERN[^$CHARSET]|^$PATTERN\$"
#          set -- "$@" -E -e "($TOKLIST)"
        else
          pushv FILES "$ARG"
          set -- "$@" -- "$ARG"
        fi
      ;;
    esac
    
  done
  
  check_chars TOKENS "$CHARSET.?*+()" TOKENS
  subst_chars TOKENS '.' "[$CHARSET]"
  subst_chars TOKENS '(' "\\("
  subst_chars TOKENS ')' "\\)"
  subst_chars TOKENS "$IFS" "|"

  set -- $OPTS -E -e "([^$CHARSET]|^)($TOKENS)([^$CHARSET]|\$)" --  $FILES
  
  
  if grep --help 2>&1 |grep -q '\--color.*='; then
     pushv OPTS "--color=auto"
   fi
  
  if "${DEBUG:-false}"; then
  echo "TOKLIST=$TOKLIST" 1>&2
    set -x
  fi
  exec grep $OPTS "$@"
}
#set -x
main "$@"
