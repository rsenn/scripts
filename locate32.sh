#!/bin/sh

IFS="
"

list-mediapath() 
{ 
    ( while :; do
        case "$1" in 
            -*)
                OPTS="${OPTS+$OPTS
}$1";
                shift
            ;;
            --)
                shift;
                break
            ;;
            *)
                break
            ;;
        esac;
    done;
    for ARG in "$@";
    do
        eval "ls -1 -d \$OPTS -- $MEDIAPATH/\$ARG 2>/dev/null";
    done )
}

[ -d /cygdrive ]  && { CYGDRIVE="/cygdrive"; : ${OS="Cygwin"}; }
(for DIR in /sysdrive/{a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}/; do [ -d "$DIR" ] && exit 0; done; exit 1)  && SYSDRIVE="/sysdrive" || SYSDRIVE=

case "${OS=`uname -o |head -n1`}" in
   msys* | Msys* |MSys* | MSYS*)
    MEDIAPATH="$SYSDRIVE/{a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}" 
    PATHTOOL=msyspath
   ;;
  *cygwin* |Cygwin* | CYGWIN*) 
    MEDIAPATH="$CYGDRIVE/{a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}" 
   set-prompt '\[\e]0;${OS}\w\a\]\n\[\e[32m\]$USERNAME@${HOSTNAME%.*} \[\e[33m\]\w\[\e[0m\]\n\$ '
   PATHTOOL=cygpath
  ;;
*) 
  MEDIAPATH="/m*/*/"
  
	set-prompt "${ansi_yellow}\\u${ansi_none}@${ansi_red}${HOSTNAME%[.-]*}${ansi_none}:${ansi_bold}(${ansi_none}${ansi_green}\\w${ansi_none}${ansi_bold})${ansi_none} \\\$ "
 ;;
esac

pathconv() { (IFS="/\\"; S="${2-/}"; set -- $1; IFS="$S"; echo "$*"); }
addopt() { for OPT; do OPTS="${OPTS:+$OPTS }${OPT}"; done; }

LOCATE=$(ls -d -- $(list-mediapath 'Prog*/Locate32/Locate.exe')|head -n1)
LOCATEDIR=$(dirname "$LOCATE")
#LOCATEREG=$(ls -d $LOCATEDIR/*.reg)
(cd "$LOCATEDIR"; for REG in *.reg; do reg import "$REG"
done)
#$(pathconv "$PROGRAMFILES")/Locate32/locate.exe
OPTS=
REGEX= NOCASE=
LOOKDIR= LOOKFILE= 
WHOLE= SIZE=

while :; do
  case "$1" in
    -p | --path) LOOKPATH="$2"; shift ;;
    -r | --regex) REGEX=true ;;
    -i | --ignore-case) NOCASE=true ;;
    -f | --file) LOOKFILE=f ;;
    -d | --dir) LOOKDIR=d ;;
    -w | --wholename) WHOLE=true ;;
    -s | 	--size) SIZE="$2"; shift ;;
    *) break ;;
  esac
  shift
done

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
echo "+ $CMD" 1>&2
eval "$CMD"