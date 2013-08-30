#!/bin/bash


OS=`uname -o`

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
  	-d|--debug) DEBUG=true; shift ;;
  	-e|--exist*) EXIST_FILE=true; shift ;;
  	-f) WANT_FILE=true; shift ;;
  -i| --ignore*case) IGNORE_CASE=true ; shift  ;;
  	-I=*| --include=*) add_dir INCLUDE_DIRS "${1#*=}" ; shift  ;;
  	-I | --include) add_dir INCLUDE_DIRS "$2" ; shift 2 ;;
  	-e|-x) add_dir EXCLUDE_DIRS "$2" ; shift 2 ;;
	*) break ;;
	esac
done



: ${OS=`uname -o`}
EXPR=""

#EXPR="($(IFS="|$IFS";  echo "$*"))"
for ARG; do
  [ -z "$EXPR" ] && EXPR="(" || EXPR="$EXPR|"
  EXPR="$EXPR$ARG"
  case "$ARG" in
      *\$) ;; 
    *) [ "$WANT_FILE" = true ] && EXPR="$EXPR[^/]*\$" ;;
  esac
done
EXPR="$EXPR)"

MOUNT_OUTPUT=`mount`

[ "$IGNORE_CASE" = true ] && GREP_ARGS="${GREP_ARGS:+$GREP_ARGS
}-i"


case "$OS" in
  Cygwin* | *cygwin*) CYGDRIVE="/cygdrive" 
MEDIAPATH="$CYGDRIVE/{a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}"
;;
*Linux*|*linux*) MEDIAPATH="/m*/*/" ;;

esac

case "$(command grep --help 2>&1)" in
  *--color*) GREP_ARGS="$GREP_ARGS --color=auto" ;;
esac

case "$OS" in
  Cygwin) DRIVEPREFIX="/cygdrive" ;;
*) test -d "/sysdrive"  && DRIVEPREFIX="/sysdrive" ;;
esac

while read C1 C2 C3 C4 C5 C6; do
  if [ "$C2" = on ]; then
    case "$C3" in
      /[a-z])
        INDEXES=`for x in a b c d e f g h i j k l m n o p q r s t u v w x y z; do test -e $DRIVEPREFIX/$x/files.list && echo $DRIVEPREFIX/$x/files.list; done`
        break
      ;;
    esac
  fi
done <<<"$MOUNT_OUTPUT"

if [ "$OS" = Cygwin -o -n "$DRIVEPREFIX" ]; then
        INDEXES=`for x in a b c d e f g h i j k l m n o p q r s t u v w x y z; do test -e $DRIVEPREFIX/$x/files.list && echo $DRIVEPREFIX/$x/files.list; done`
fi

: ${INDEXES="$MEDIAPATH/files.list"}
CMD="ls -d $MEDIAPATH/files.list 2>/dev/null"
: ${INDEXES:=$(eval "$CMD")}

FILTERCMD="sed -u 's,/files.list:,/,'"

if [ "$EXIST_FILE" = true ]; then
  FILTERCMD="$FILTERCMD | while read -r FILE; do test -e \"\$FILE\" && echo \"\$FILE\"; done"
fi
if [ -n "$INCLUDE_DIRS" ]; then
  INCLUDE_DIR_EXPR=`grep-e-expr $INCLUDE_DIRS`
  FILTERCMD="$FILTERCMD |grep -E \"^$INCLUDE_DIR_EXPR\""
fi
if [ -n "$EXCLUDE_DIRS" ]; then
  EXCLUDE_DIR_EXPR=`grep-e-expr $EXCLUDE_DIRS`
  FILTERCMD="$FILTERCMD |grep -v -E \"^$EXCLUDE_DIR_EXPR\""
fi

set -- $INDEXES 

[ "$DEBUG" = true ] && echo "EXPR is $EXPR" 1>&2

CMD="grep $GREP_ARGS -H -E \"\$EXPR\" \$INDEXES | $FILTERCMD"

[ "$DEBUG" = true ] && echo "Command is $CMD" 1>&2
eval "($CMD) 2>/dev/null" 
