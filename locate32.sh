#!/bin/sh

IFS="
"

OPTS=
REGEX= NOCASE=
LOOKDIR= LOOKFILE= 
WHOLE= SIZE=

usage()
{
  echo "Usage: ${0##*/} [OPTIONS] PATTERN

  -h, --help           Show this help
  -p, --path=PATH      Look in path
  -r, --regex          Regular expression search
  -i, --ignore-case    Case insensitive search
  -f, --file           Look for a file
  -d, --dir            Look for a directory
  -s, --size=SIZE      Specify file size
  -t, --extension=EXT  Specify file extension
  -x, --debug          Show debug messages
"
}

DATABASE=$(reg query 'HKCU\Software\Update\Databases\1_default' /v ArchiveName |sed -n 's,\\,/,g ;; s,.*REG_SZ\s\+,,p')

while :; do
  case "$1" in
    --) shift; break ;;
    -h | --help) usage; exit 0 ;;
    -p | --path) LOOKPATH="$2"; shift ;; -p=* | --path=*) LOOKPATH="${1#*=}" ;;
    -r | --regex) REGEX=true ;;
    -i | --ignore-case) NOCASE=true ;;
    -f | --file) LOOKFILE=f ;;
    -d | --dir) LOOKDIR=d ;;
    -b | -D | --database) DATABASE="$2" ; shift ;;
    -t) EXTENSION="$2" ; shift ;;  --ext*=*) EXTENSION="${1#*=}" ;;
    -w | --wholename) WHOLE=true ;;
    -s | --size) SIZE="$2"; shift ;; -s=* | --size=*) SIZE="${1#*=}" ;;
    -x | --debug) DEBUG=true ;;
    *) break ;;
  esac
  shift
done
PARAMS="$*"
echo "PARAMS:" $PARAMS 1>&2
echo "DATABASE:" $DATABASE 1>&2

#: ${DATABASE="$USERPROFILE/AppData/Roaming/Locate32/files.dbs"}

MEDIAPATH="/{$(set -- $(df -a 2>/dev/null |sed -n 's,^[A-Za-z]\?:\?[\\/]\?[^ ]*\s[^/]\+\s/,,p'); IFS=","; echo "$*")}"

pathconv() { (IFS="/\\"; S="${2-/}"; set -- $1; IFS="$S"; echo "$*"); }
addopt() { for OPT; do OPTS="${OPTS:+$OPTS }${OPT}"; done; }

LOCATE=`eval "ls -d -- $MEDIAPATH/Prog*/Locate32/Locate.exe" 2>/dev/null|head -n1`

[ "$DEBUG" = true ] && echo "Found locate at: $LOCATE" 1>&2 

LOCATEDIR=$(dirname "$LOCATE")
#LOCATEREG=$(ls -d $LOCATEDIR/*.reg)
(cd "$LOCATEDIR"; for REG in *.reg; do test -f "$REG" && reg import "$REG"
done)
#$(pathconv "$PROGRAMFILES")/Locate32/locate.exe


case "${NOCASE:-false}:${REGEX:-false}" in
  true:false) addopt -lcn ;;
  true:true) addopt -rc ;;
  false:true) addopt -r ;;
esac

if [ -n "$DATABASE" ]; then
  saved_IFS="$IFS"
  IFS=";
"
  for DB in $DATABASE; do
    [ -e "$DB" ] && addopt -d "$DB"
  done
  IFS="$saved_IFS"
fi

if [ -n "$EXTENSION" ]; then
  addopt -t "$EXTENSION"
fi

if [ -z "${LOOKFILE}${LOOKDIR}${LOOKWHOLE}" ]; then
  LOOKFILE=f
fi

addopt -l"${LOOKFILE}${LOOKDIR}${LOOKWHOLE}"
addopt -lrn

case "$SIZE" in
  +*) addopt -lm:"${SIZE#?}" ;;
  -*) addopt -lM:"${SIZE#?}" ;;
esac

[ "$WHOLE" = true ] && addopt -w
[ "$LOOKPATH" ] && addopt -p "$(pathconv "$LOOKPATH" "\\")"

#SED_EXPR="s|\\\\\\\\|/|g"
SED_EXPR="s|\\\\|/|g"
#SED_EXPR="${SED_EXPR}; s|^a|A|; s|^b|B|; s|^c|C|; s|^d|D|; s|^e|E|; s|^f|F|; s|^g|G|; s|^h|H|; s|^i|I|; s|^j|J|; s|^k|K|; s|^l|L|; s|^m|M|; s|^n|N|; s|^o|O|; s|^p|P|; s|^q|Q|; s|^r|R|; s|^s|S|; s|^t|T|; s|^u|U|; s|^v|V|; s|^w|W|; s|^x|X|; s|^y|Y|; s|^z|Z|"
SED_EXPR="${SED_EXPR}; s|^A|a|; s|^B|b|; s|^C|c|; s|^D|d|; s|^E|e|; s|^F|f|; s|^G|g|; s|^H|h|; s|^I|i|; s|^J|j|; s|^K|k|; s|^L|l|; s|^M|m|; s|^N|n|; s|^O|o|; s|^P|p|; s|^Q|q|; s|^R|r|; s|^S|s|; s|^T|t|; s|^U|u|; s|^V|v|; s|^W|w|; s|^X|x|; s|^Y|y|; s|^Z|z|"

unset ARGS
for ARG in $PARAMS; do
  case "$ARG" in
    *\[^/\]* | *\[^\\\]* | *\[^\\\\\]*) ;;
    *[/\\]*) addopt -w ;;
  esac
  ARG=${ARG//"\\."/"\\{dot}"}
  ARG=${ARG//".*"/"*"}
  ARG=${ARG//"."/"?"}
  ARG=${ARG//"\\?"/"."}
  ARG=${ARG//"/"/"\\"}
  ARG=${ARG//"\\{dot}"/"."}
  case "$ARG" in
    ^*\$) ARG=${ARG#^}; ARG="${ARG%\$}" ;;
    *\$) ARG="*${ARG%\$}" ;;
    ^*) ARG="${ARG#^}*" ;;
    *) ARG="*${ARG}*" ;;
  esac
  ARGS="${ARGS+$ARGS
}$ARG"
done
#ARGS=${ARGS//"**"/"*"}
ARGS=$(echo "$ARGS" | sed 's,\*\+,*,g')

addopt -lw
set -f
CMD="\"$LOCATE\" $OPTS -- \"\$ARG\""
CMD="for ARG in \$ARGS; do (${DEBUG:+set -x; }$CMD) done"
CMD="$CMD | sed \"\${SED_EXPR}\""
#[ "$DEBUG" = true ] && echo "+ $CMD" 1>&2
eval "$CMD"
