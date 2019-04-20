#!/bin/bash

TS='	'
NL='
'
vget() {
  (IFS=" ;$NL"; set -- $(var_get "$1" )
  echo "$*")
}

cmd_for() {
 (MODE=$1
  set -- '$(CFLAGS)' '$(DEFS)' '$(CPPFLAGS)' 
  case "$MODE" in
    PREPROC) set -- "$@" -E ;;
    COMPILE) set -- "$@" -c ;;
    ASSEMBLER) set -- "$@" -S ;;
    LINK) set -- '$(LDFLAGS)' "$@" ;;
  esac
  set -- '$(CC)' "$@" '$(CFLAGS)' ${OUTPUT:+-o "$OUTPUT"} $ARGS

  (IFS=" "; echo "$*"))
}


makefile_from_build_log() {

 (trap 'rm -f "$TEMP1" "$TEMP2"' EXIT
  TEMP1=`mktemp`
  TEMP2=`mktemp`

  while :; do
    case "$1" in
      *) break ;;
    esac
  done

  while read -r LINE; do
    eval "IFS=' '; set -- \$LINE; IFS='$NL'"
    MODE=LINK
    OUTPUT=
    ARGS=
    CMD="$1"
    shift
    while [ $# -gt 0 ]; do
      case "$1" in
#        *=\"*)
#          NAME=${ARG%%=*}; VALUE=${ARG#*=}; VALUE=${VALUE#\"}; VALUE=${VALUE%\"}
#		  matchany "$NAME=*" $VARS || pushv VARS "$NAME=$VALUE"; shift
#         ;;
        -D) pushv_unique DEFINES "$2"; shift 2 ;; -D*) pushv_unique DEFINES "${1#-D}"; shift ;;
        -I) pushv_unique INCLUDES "$2"; shift 2 ;; -I*) pushv_unique INCLUDES "${1#-I}"; shift ;;
        -L) pushv_unique LIBPATH "$2"; shift 2 ;; -L*) pushv_unique LIBPATH "${1#-L}"; shift ;;
        -l) pushv_unique LIBS "$2"; shift 2 ;; -l*) pushv_unique LIBS "${1#-l}"; shift ;;
        -o) OUTPUT=$2; shift 2 ;; -o*) OUTPUT=${1#-o}; shift ;;
        -c) MODE=COMPILE; shift ;;
        -E) MODE=PREPROC; shift ;;
        -S) MODE=ASSEMBLER; shift ;;
        *.tmp|*.d) shift ;;
        *.o) shift ;;
        -*) pushv_unique CFLAGS "$1"; shift ;;
        *) pushv_unique ARGS "$1"; shift ;;
      esac
    done
    if [ "$COMPILE" != true -a "$PREPROC" != true -a  "$ASSEMBLE" != true ]; then
      LINK=true
    fi
    echo "VARS=$VARS" 1>&2
    echo "ARGS=$ARGS" 1>&2

    set -- "\$($MODE)" ${OUTPUT:+-o "$OUTPUT"} $ARGS
    #[ -n "$OUTPUT" ] || 
    (IFS=" $IFS"; echo "$OUTPUT": $ARGS; echo "$TS$*")
     
  done >"$TEMP1"

  : ${CC:=gcc}
  DEFS=`addprefix -D $DEFINES`
  CPPFLAGS=`addprefix -I $INCLUDES`
  LDFLAGS=`addprefix -L $LIBPATH`
  LIBS=`addprefix -l $LIBS`

 (for VAR in CC DEFS CPPFLAGS LDFLAGS LIBS CFLAGS; do
   eval "echo $VAR = \${$VAR}"
  done 
  cat "$TEMP1") >"$TEMP2"


  mv -vf "$TEMP2" Makefile.out


  )
}

addline()
{
    eval "shift;$1=\"\${$1+\"\$$1\${NL}\"}\$*\""
}
pushv()
{
    eval "shift;$1=\"\${$1+\"\$$1\${IFS%\"\${IFS#?}\"}\"}\$*\""
}
addprefix()
{
    ( PREFIX=$1;
    shift;
    CMD='echo "$PREFIX$LINE"';
    [ $# -gt 0 ] && CMD="for LINE; do $CMD; done" || CMD="while read -r LINE; do $CMD; done";
    eval "$CMD" )
}
var_get()
{
    eval "echo \"\$$1\""
}

pushv_unique() {
    local v=$1 s IFS=${IFS%${IFS#?}};
    shift
    eval "for s in \${$v}; do
     [ \"\$s\" = \"\$1\" ] && return 1 
   done; $v=\"\${$v}${NL}\$1\""
}
isin ()
{
    ( needle="$1";
    while [ "$#" -gt 1 ]; do
        shift;
        test "$needle" = "$1" && exit 0;
    done;
    exit 1 )
}
matchany() {   
 (STR="$1"
  shift
  set -o noglob
  for EXPR in "$@"; do  
	case "$STR" in
	  *$EXPR*) exit 0 ;;
	  *) ;;
	esac
  done
  exit 1)
}



makefile_from_build_log "$@"
