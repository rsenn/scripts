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
  -x, --debug          Show debug messages
"
  exit 0
}

while :; do
  case "$1" in
    -h | --help) usage; shift ;;
    -p | --path) LOOKPATH="$2"; shift 2 ;; -p=* | --path=*) LOOKPATH="${1#*=}"; shift ;;
    -r | --regex) REGEX=true ;;
    -i | --ignore-case) NOCASE=true ;;
    -f | --file) LOOKFILE=f ;;
    -d | --dir) LOOKDIR=d ;;
    -w | --wholename) WHOLE=true ;;
    -s | 	--size) SIZE="$2"; shift 2 ;; -s=* | --size=*) SIZE="${1#*=}"; shift ;;
    -x | --debug) DEBUG=true; shift ;;
    *) break ;;
  esac
  shift
done

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


CMD="exec \"$LOCATE\" $OPTS -- \"$@\" | sed \"\${SED_EXPR}\""
[ "$DEBUG" = true ] && echo "+ $CMD" 1>&2
eval "$CMD"
