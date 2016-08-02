#!/bin/bash
type ${SED-sed} 1>/dev/null 2>/dev/null && SED=${SED-sed} || SED=${SED-sed}
MYNAME=`basename "${0%.sh}"`
MYDIR=`dirname "$0"`
IFS="
"
unset FUNCTIONS

pushv() 
{ 
      eval "shift;$1=\"\${$1+\"\$$1\${IFS%\"\${IFS#?}\"}\"}\$*\""
}

str_triml()
{   
     s=$1 t= x=${2-${IFS:-$space$nl$tabstop}};
    while t="${s#[$x]}" && test "$t" != "$s"; do
        s="$t";
    done;
    echo "$s"
}

functions_assemble() {
     while :; do
        case "$1" in
          -x | --debug) DEBUG=true; shift ;;
          *) break ;;
        esac
      done
      

    if [ -n "$1" -a -d "$1" ]; then
     SOURCE_DIR="$1"
     shift
    else
      SOURCE_DIR=$MYDIR/functions
    fi
#		echo "SOURCE_DIR=$SOURCE_DIR" 1>&2
    ARGS="$*"
    set -- $(ls -tdr $SOURCE_DIR/*.sh)
    set -- `echo "$*" |sort -fu` 
 #  echo "#=$#" 1>&2
    for FILE ;  do
      FILENAME=${FILE##*/}
      NAME=${FILENAME%.sh}
      FNBODY=$($SED '1 { s|\s*()\s*$|()| }' "$FILE")
      FNBODY=`str_triml "$FNBODY"` 
     [ "$FUNCTIONS" ] && pushv FUNCTIONS ""
      pushv FUNCTIONS "$FNBODY"
    done
    output $ARGS
}

output() {
    CMD='echo -e "#!/bin/bash\n"
    echo "$FUNCTIONS"'
    if [ -n "$1" ]; then
      TMP=${MYNAME}-$$.tmp
      trap  'rm -f "$TMP"' EXIT
      CMD="{ $CMD; } >\"\$TMP\"; mv -f \"\$TMP\" \"\$1\"; echo \"Wrote '\$1'.\" 1>&2"
    fi
#    echo "CMD='$CMD'" 1>&2 
    eval "$CMD"
}

functions_assemble "$@"
