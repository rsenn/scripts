#!/bin/bash
#
# substitute name token
#
# $ID: $

pushv() { eval "shift;$1=\"\${$1+\"\$$1\${IFS%\"\${IFS#?}\"}\"}\$*\""; }


check_chars() {
  eval INVAL='${'$1"%%*[!${2-$CHARSET}]*}"

  if [ -z "$INVAL" ]; then
    echo "${0##*/}: ${3+$3 }must contain characters from [${2-$CHARSET}] only. ($INVAL)" 1>&2
    exit 1
  fi
}

subst_chars() {
  eval $1='${'$1"//$2/'$3'}"
}

num_refs() {
  IFS="\\" REF=0 SPLIT=

  set -- $PATTERN

  for SPLIT; do
    case $SPLIT in
      '('*) REF=`expr $REF + 1` ;;
      ')'*) REF=`expr $REF - 1` ;;
    esac
  done

  if [ "$REF" != 0 ]; then
    echo "${0##*/}: improperly balanced parenthesis in PATTERN" 1>&2
    exit 1
  fi

  return $(( ($# - 1) / 2 ))
}

shift_refs() {
  IFS="\\" X=$1 OUT=$2
  set -- $REPLACE
  eval $OUT='$1'
  shift
  for SPLIT; do
    STRIP=${SPLIT#[0-9]}
    N=${SPLIT%"$STRIP"}
    if [ -z "$N" -o "$N" -gt "$NREF" ]; then
      echo "${0##*/}: invalid reference near \\$SPLIT" 1>&2
      exit 1
    fi
    echo $OUT='"$'$OUT"\\"$((N+X))"$STRIP\""
    eval $OUT='"$'$OUT"\\"$((N+X))'$STRIP"'
  done
}

toksubst() {

 (debug() {
    ${DEBUG:-false} && echo "DEBUG: $@" 1>&2
  }
  CHARSET=$EXTRACHARS'0-9A-Za-z_' COUNT=0

  unset OPTS PATTERN REPLACE SCRIPT PREV

  #DEBUG=true debug "echo $0 $@"

  while :; do
    case "$1" in
        --debug | -x) DEBUG=:; shift ;;
        --print | -p) PRINT=:; shift ;;
       -*) OPTS="${OPTS:+$OPTS
}$1"; shift ;;
      *) break ;;
    esac
  done

  ARGS=
  for ARG; do
    if [ "$COUNT" = 0 ]; then
      set --
    fi

    COUNT=`expr $COUNT + 1`

    if [ -N "${PREV+set}" ]; then
      set -- "$@" "$PREV" "$ARG"
      unset PREV
      continue
    fi

    case $ARG in
      -e|-f|-l)
        PREV=$ARG
        continue
      ;;

      -*)
        set -- "$@" "$ARG"
      ;;

      *)
        if [ -z "${PATTERN+set}" ]; then
          PATTERN=$ARG
  #        check_chars PATTERN "$CHARSET.?*+()" PATTERN
          subst_chars PATTERN '.' "[$CHARSET]"
          subst_chars PATTERN '(' "\\("
          subst_chars PATTERN ')' "\\)"
          num_refs; NREF=$?
        elif [ -z "${REPLACE+set}" ]; then
          REPLACE=$ARG
          check_chars REPLACE "$CHARSET\\\\0-9"
          shift_refs 1 shifted
          SCRIPT="/$PATTERN/ { \
s,\([^$CHARSET]\)$PATTERN\([^$CHARSET]\),\\1$shifted\\$((NREF+2)),g; \
s,\([^$CHARSET]\)$PATTERN\$,\\1$shifted,g; \
s,^$PATTERN\([^$CHARSET]\),$REPLACE\\$((NREF+1)),g; \
s,^$PATTERN\$,$REPLACE,g; \
}"
          CMD='sed -e "$SCRIPT" $ARGS'
        else
          pushv ARGS "$ARG"
        fi
      ;;
    esac

  done
  ${PRINT-false} && CMD='echo "$SCRIPT"'
  #set -X
  debug "CMD: $CMD"
eval "$CMD \"\$@\"")
#  exec ${SED-sed} "$@"
}

case "${0##*/}" in
  -* | sh | bash) ;;
  *) toksubst "$@" || exit $? ;;
esac

