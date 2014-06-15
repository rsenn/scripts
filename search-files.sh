#!/bin/bash

grep-e-expr()
{ 
    echo "($(IFS="|
	 $IFS";  set -- $*; echo "$*"))"
}

is_relative()
{ 
  case "$1" in 
    /*) return 1 ;;
    *) return 0 ;;
  esac
}

type realpath 2>/dev/null >/dev/null || realpath()
{ 
 (if test -d "$1"; then
    cd "$1"
    pwd
  fi)  
}

add_dir()
{
  CMD="REALDIR=\$(realpath \"\$2\")
  [ -d \"\$REALDIR\" -a \"\$2\" != \"\$REALDIR\" ] || unset REALDIR
  $1=\"\${$1+\$$1
}\$2\${REALDIR+
\$REALDIR}\"
  shift"
  eval "$CMD"
}

unset INCLUDE_DIRS


while :; do
	case "$1" in
  	-f) WANT_FILE=true; shift ;;
  	-i) add_dir INCLUDE_DIRS "$2" ; shift 2 ;;
  	-e|-x) add_dir EXCLUDE_DIRS "$2" ; shift 2 ;;
	*) break ;;
	esac
done




EXPR="($(IFS=" $IFS"; set -- $*; echo "$*"))"

if [ "$WANT_FILE" = true ]; then
  EXPR="$EXPR[^/]*\$"
fi

MOUNT_OUTPUT=`mount`
MEDIAPATH="/m*/*"
GREP_ARGS="-i"

case "$(command grep --help 2>&1)" in
  *--color*) GREP_ARGS="$GREP_ARGS --color=auto" ;;
esac

while read C1 C2 C3 C4 C5 C6; do
  if [ "$C2" = on ]; then
    case "$C3" in
      /[a-z])
        INDEXES=`for x in a b c d e f g h i j k l m n o p q r s t u v w x y z; do test -e /$x/files.list && echo /$x/files.list; done`
        break
      ;;
    esac
  fi
done <<<"$MOUNT_OUTPUT"

: ${INDEXES="$MEDIAPATH/files.list"}
FILTERCMD="sed -u 's,/files.list:,/,'"


if [ -n "$INCLUDE_DIRS" ]; then
  INCLUDE_DIR_EXPR=`grep-e-expr $INCLUDE_DIRS`
  FILTERCMD="$FILTERCMD |grep -E \"^$INCLUDE_DIR_EXPR\""
fi
if [ -n "$EXCLUDE_DIRS" ]; then
  EXCLUDE_DIR_EXPR=`grep-e-expr $EXCLUDE_DIRS`
  FILTERCMD="$FILTERCMD |grep -v -E \"^$EXCLUDE_DIR_EXPR\""
fi

set -- $INDEXES 

#echo "$# Indexes" 1>&2

case "$EXPR" in
  *'$')
   EXPR=${EXPR%'$'}"/?\$"
   ;;
esac

CMD="grep $GREP_ARGS -H -E \"\$EXPR\" \$INDEXES | $FILTERCMD"
#echo "Command is $CMD" 1>&2
eval "($CMD) 2>/dev/null" 
