#!/bin/bash

MYNAME=`basename "$0" .sh` 
IFS=$'\n\r'

NL="
"
OPTS=
REGEX= NOCASE=
LOOKDIR= LOOKFILE= 
WHOLE= SIZE=

msg() {
	echo "${MYNAME}: $@" 1>&2
}

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
  -b, --database=FILE  Specify database file
  -t, --extension=EXT  Specify file extension
  -x, --debug          Show debug messages
"
}

while :; do
  case "$1" in
    --) shift; break ;;
    -h | --help) usage; exit 0 ;;
    -e | --exist*) EXISTS="true" ;;
    -p | --path) LOOKPATH="$2"; shift ;; -p=* | --path=*) LOOKPATH="${1#*=}" ;;
    -r | --regex) REGEX=true ;;
    -i | --ignore-case) NOCASE=true ;;
    -f | --file) LOOKFILE=f ;;
    -d | --dir) LOOKDIR=d ;;
    -b | -D | --database) DATABASE="${DATABASE:+$DATABASE;}$2" ; shift ;;
    -b=* | -D=* | --database=*) DATABASE="${DATABASE:+$DATABASE;}${1#*=}" ;;
    -t | -E) EXTENSION="${EXTENSION:+$EXTENSION
}$2" ; shift ;;  -[tE]=* | --ext*=*) EXTENSION="${EXTENSION:+$EXTENSION
}${1#*=}" ;;
    -t* | -E*) EXTENSION="${EXTENSION:+$EXTENSION
}${1#-?}"  ;; 
    -w | --wholename) WHOLE=true ;;
    -s | --size) SIZE="$2"; shift ;; -s=* | --size=*) SIZE="${1#*=}" ;;
    -x | --debug) DEBUG=true ;;
    -c | --class) CLASS="$2"; shift ;; -c=* | --class=*) CLASS="${1#*=}" ;; -c*) CLASS="${1#-c}" ;;
    *) break ;;
  esac
  shift
done
set -f

if type reg 2>/dev/null >/dev/null; then
	REG="reg"
fi


#: ${DATABASE=$("$REG" query 'HKCU\Software\Update\Databases\1_default' -v ArchiveName |sed -n 's,\\,/,g ;; s,.*REG_SZ\s\+,,p')}

: ${DATABASE="$USERPROFILE/AppData/Roaming/Locate32/files.dbs"}

if [ -n "$REG" ]; then
: ${DATABASE="$(for key in $("$REG" query 'HKCU\Software\Update\Databases' #| sed 's,\r$,,'
); do key=${key%$'\r'}; test -z "$key" || reg query "$key" -v ArchiveName |sed -n '/ArchiveName/ { s,\r$,,; s,.*REG_SZ\s\+,,; s,\\,/,g; p; }'; done)"}
fi

if [ -z "$DATABASE" ]; then
	msg "Missing database!"
	exit 1
fi


#: ${DATABASE="$USERPROFILE/AppData/Roaming/Locate32/files.dbs"}

[ "$#" -le 0 ] && set -- "*"

PARAMS="$*"

if [ "$DEBUG" = true ]; then
	echo "PARAMS:" $PARAMS 1>&2
	echo "DATABASE:" $DATABASE 1>&2
fi


MEDIAPATH="/{$(set -- $(df -a 2>/dev/null |sed -n 's,^[A-Za-z]\?:\?[\\/]\?[^ ]*\s[^/]\+\s/,,p'); IFS=","; echo "$*")}"

pathconv() { (IFS="/\\"; S="${2-/}"; set -- $1; IFS="$S"; echo "$*"); }
addopt() { for OPT; do OPTS="${OPTS:+$OPTS }${OPT}"; done; }

LOCATE=`set +f; eval "ls -d -- $MEDIAPATH/Prog*/Locate32/Locate.exe" 2>/dev/null|head -n1`

[ "$DEBUG" = true ] && echo "Found locate at: $LOCATE" 1>&2 

LOCATEDIR=$(dirname "$LOCATE")
#LOCATEREG=$(ls -d $LOCATEDIR/*.reg)

#(cd "$LOCATEDIR"; for REG in *.reg; do test -f "$REG" && reg import "$REG"; done)
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
    #[ -e "$DB" ] && 
    addopt -d "$DB"
  done
  IFS="$saved_IFS"
fi


case "$CLASS" in
  bin*|exe*|prog*)  EXTENSION="${EXTENSION:+$EXTENSION$NL}exe${NL}msi${NL}dll" ;;
  playlist*) EXTENSION="${EXTENSION:+$EXTENSION$NL}m3u${NL}m3u8${NL}pls${NL}asx${NL}xspf${NL}asxini${NL}cue${NL}wpl" ;;
  archive*) EXTENSION="${EXTENSION:+$EXTENSION$NL}7z${NL}rar${NL}tar\.bz2${NL}tar\.gz${NL}tar\.xz${NL}tar${NL}tar\.lzma${NL}tbz2${NL}tgz${NL}txz${NL}zip" ;;
  *audio*) EXTENSION="${EXTENSION:+$EXTENSION$NL}aif${NL}aiff${NL}flac${NL}raw${NL}wav" ;;
  fonts*) EXTENSION="${EXTENSION:+$EXTENSION$NL}bdf${NL}flac${NL}fon${NL}m4a${NL}m4b${NL}mp3${NL}mpc${NL}ogg${NL}otf${NL}pcf${NL}rm${NL}ttf${NL}wma" ;;
  image*) EXTENSION="${EXTENSION:+$EXTENSION$NL}bmp${NL}cin${NL}cod${NL}dcx${NL}djvu${NL}emf${NL}fig${NL}gif${NL}ico${NL}im1${NL}im24${NL}im8${NL}jin${NL}jpeg${NL}jpg${NL}lss${NL}miff${NL}opc${NL}pbm${NL}pcx${NL}pgm${NL}pgx${NL}png${NL}pnm${NL}ppm${NL}psd${NL}rle${NL}rmp${NL}sgi${NL}shx${NL}svg${NL}tga${NL}tif${NL}tiff${NL}wim${NL}xcf${NL}xpm${NL}xwd" ;;
  iso*|nero*|cue*|optical*|dvd*|*disk*image*) EXTENSION="${EXTENSION:+$EXTENSION$NL}bin${NL}cdi${NL}daa${NL}iso${NL}mdf${NL}mds${NL}nrg" ;;
  incompl*|part*) EXTENSION="${EXTENSION:+$EXTENSION$NL}\*\.!??${NL}\*\.part${NL}INCOMPL\*${NL}\[/\\\]INCOMPL\[^/\\\]\*\$${NL}\\\.!??\$${NL}\\\.part\$" ;;
  *music*) EXTENSION="${EXTENSION:+$EXTENSION$NL}m4a${NL}m4b${NL}mp3${NL}mpc${NL}ogg${NL}rm${NL}wma" ;;
  package*|pkg*) EXTENSION="${EXTENSION:+$EXTENSION$NL}deb${NL}rpm${NL}tgz${NL}txz" ;;
  patch*|diff*) EXTENSION="${EXTENSION:+$EXTENSION$NL}diff${NL}patch)[^/]*$" ;;
  script*) EXTENSION="${EXTENSION:+$EXTENSION$NL}bat${NL}cmd${NL}py${NL}rb${NL}sh" ;;
  software*) EXTENSION="${EXTENSION:+$EXTENSION$NL}\*\.msi${NL}\*install\*\.exe${NL}\*setup\*\.exe${NL}\.msi${NL}7z${NL}deb${NL}exe${NL}install\*\.exe${NL}msi${NL}rar${NL}rpm${NL}setup\*\.exe${NL}tar\.bz2${NL}tar\.gz${NL}tar\.xz${NL}tbz2${NL}tgz${NL}txz${NL}zip" ;;
  source*) EXTENSION="${EXTENSION:+$EXTENSION$NL}c${NL}cpp${NL}cxx${NL}h${NL}hpp${NL}hxx" ;;
  video*) EXTENSION="${EXTENSION:+$EXTENSION$NL}3gp${NL}avi${NL}f4v${NL}flv${NL}m2v${NL}mkv${NL}mov${NL}mp4${NL}mpeg${NL}mpg${NL}ogm${NL}vob${NL}wmv" ;;
  vmware*|vbox*|virt*|v*disk*|vdi*|qed*|qcow*|qemu*|vmdk*|vdisk*) EXTENSION="${EXTENSION:+$EXTENSION$NL}vdi${NL}vmdk${NL}vhd${NL}qed${NL}qcow${NL}qcow2${NL}raw${NL}vhdx${NL}hdd" ;;
  pdf|doc*) EXTENSION="${EXTENSION:+$EXTENSION$NL}pdf${NL}epub${NL}mobi${NL}azw3${NL}djv${NL}djvu" ;;
  *book*|epub|mobi) EXTENSION="${EXTENSION:+$EXTENSION$NL}epub${NL}mobi${NL}azw3${NL}djv${NL}djvu" ;;
font*|truetype*) EXTENSION="${EXTENSION:+$EXTENSION$NL}ttf${NL}otf${NL}bdf${NL}pcf${NL}fon${NL}pfa${NL}pfb${NL}pt3${NL}t42${NL}sfd${NL}otb${NL}cff${NL}cef${NL}gai${NL}woff${NL}pf3${NL}ttc${NL}gsf${NL}cid${NL}dfont${NL}mf${NL}ik${NL}fnt${NL}pcf${NL}pmf" ;;
	'') ;;
  *) echo "No such class '$CLASS'." 1>&2; exit 2 ;;
esac

if [ -n "$EXTENSION" ]; then
  for E in $EXTENSION; do
    addopt -t "$E"
  done
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
SED_EXPR="$SED_EXPR; /^ERROR: The system was unable to find the specified registry key or value./d"

unset ARGS
for ARG in $PARAMS; do
  case "$ARG" in
    */* | *\\*) addopt -lW ;;
  esac
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

#[ -n "$EXTENSION" ] && addopt -t "$EXTENSION"

addopt -lw
set -f
CMD="\"$LOCATE\" $OPTS -- \"\$ARG\" 2>&1"
CMD="for ARG in \$ARGS; do (${DEBUG:+set -x; }$CMD) done"
CMD="$CMD | sed \"\${SED_EXPR}\""
[ "$DEBUG" = true ] && { echo "+ $CMD" 1>&2; : set -x; }
[ "$EXISTS" = true ] && CMD="$CMD | while read -r R; do test -e \"\$R\" && echo \"\$R\"; done"
eval "$CMD"
