#!/bin/bash

OS=`uname -o`
NL='
'

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


cut_ls_l() 
{ 
    ( I=${1:-6};
    set --;
    while [ "$I" -gt 0 ]; do
        set -- "ARG$I" "$@";
        I=`expr $I - 1`;
    done;
    IFS=" ";
    CMD="while read  -r $* P; do  echo \"\${P}\"; done";
    eval "$CMD" )
}

unset INCLUDE_DIRS
GREP_ARGS=""

usage()
{
  echo "Usage: ${0##*/} [OPTIONS] ARGUMENTS...
  -p, --mediapath=PATH     List of search paths.
  -x, --debug              Show debug messages
  -e, --exists             Show only existing files
  -f, --want-file         Return only files
  -i, --case-insensitive  Case insensitive search
  -I, --case-sensitive    Case sensitive search
      --color             Return colored list
      --include=DIR       Include results in DIR
  -x, --exclude=DIR       Exclude results from DIR
  -c, --class              File type class
  -m, --mixed             Mixed paths (see cygpath)
  -l, --list              List
  -S, --sort              Sort
  One of: 
    bin|exe|prog, archive, audio, fonts, image, incompl|part,
    music, package|pkg, patch|diff, script, software, source, video,
    vmware|vbox|virt|vdisk|vdi|qed|qcow|qemu|vmdk|vdisk, pdf|doc,
    book|epub|mobi, font|truetype
"
  exit 0
}

EXCLUDE_DIRS='.*/\.wine/drive.*/\.wine/drive'

while :; do
	case "$1" in
	  -h | --help) usage; shift ;;
  	-p | --mediapath) MEDIAPATH="$2"; shift 2 ;; -m=* | --mediapath=*) MEDIAPATH="${1#*=}"; shift ;;
  	-x | --debug) DEBUG=true; shift ;;
  	-e | --exist*) EXIST_FILE=true; shift ;;
  	-m | --mix*) MIXED_PATH=true; shift ;;
  	-S=* | --sort=*) 
			case "${1#*=}" in
				time*) SORT="time" ;;
				size*) SORT="size" ;;
				*) SORT="${1#*=}" ;;
			esac
			shift
		;;
  	-S | --sort) SORT="size"; shift ;;
  	-l=* | --list=*) LIST="${1#*=}"; shift ;;
  	-l | --list) LIST='--time-style=+%s -l'; shift ;;
  	-c | --class) CLASS="$2"; shift 2 ;; -c=*|--class=*) CLASS="${1#*=}"; shift ;;
  	-f | --*file*) WANT_FILE=true; shift ;;
    -I | --case-sensitive) CASE_SENSITIVE=true ; shift ;;
    -i | --case-insensitive) CASE_SENSITIVE=false; shift ;;
    --color) GREP_ARGS="${GREP_ARGS:+$IFS}--color"; shift ;;
  	--include) add_dir INCLUDE_DIRS "$2" ; shift 2 ;; --include=*) add_dir INCLUDE_DIRS "${1#*=}"; shift ;;
  	-[EeXx] |--exclude) add_dir EXCLUDE_DIRS "$2" ; shift 2 ;; -[EeXx]=* | --exclude=*) add_dir EXLUDE_DIRS "${1#*=}"; shift ;;
  -*) echo "No such option '$1'." 1>&2; exit 1 ;;
  --) shift; break ;;	*) break ;;
	esac
done

if [ "$CASE_SENSITIVE" != true ]; then
  GREP_ARGS="${GREP_ARGS:+$IFS}-i"
fi

if [ "$WANT_FILE" = true ]; then
  MATCH_ALL="[^/]*"
else
  MATCH_ALL=".*"
fi

: ${OS=`uname -o`}
EXPR=""

#EXPR="($(IFS="|$IFS";  echo "$*"))"
if [ $# -le 0 ]; then
				EXPR=".*"
else
				for ARG; do
					[ -z "$EXPR" ] && EXPR="(" || EXPR="$EXPR|"
					EXPR="$EXPR$ARG"
					case "$ARG" in
							*\$) ;; 
						*) if [ "$WANT_FILE" = true ]; then
						   EXPR=${EXPR//'.*'/'[^/]*'}
						   EXPR="$EXPR[^/]*\$"

						 fi ;;
					esac
				done
				EXPR="$EXPR)"
fi

case "$CLASS" in
  bin*|exe*|prog*)  EXPR="${EXPR//\$)/)}${MATCH_ALL}\.(exe|msi|dll)\$" ;;
  archive*) EXPR="${EXPR//\$)/)}${MATCH_ALL}\.(7z|rar|tar\.bz2|tar\.gz|tar\.xz|tar|tar\.lzma|tbz2|tgz|txz|zip)\$" ;;
  audio*) EXPR="${EXPR//\$)/)}${MATCH_ALL}\.(aif|aiff|flac|m4a|m4b|mp2|mp3|mpc|ogg|raw|rm|wav|wma)\$" ;;
  fonts*) EXPR="${EXPR//\$)/)}${MATCH_ALL}\.(bdf|flac|fon|m4a|m4b|mp3|mpc|ogg|otf|pcf|rm|ttf|wma)\$" ;;
  image*) EXPR="${EXPR//\$)/)}${MATCH_ALL}\.(bmp|cin|cod|dcx|djvu|emf|fig|gif|ico|im1|im24|im8|jin|jpeg|jpg|lss|miff|opc|pbm|pcx|pgm|pgx|png|pnm|ppm|psd|rle|rmp|sgi|shx|svg|tga|tif|tiff|wim|xcf|xpm|xwd)\$" ;;
  incompl*|part*) EXPR="${EXPR//\$)/)}${MATCH_ALL}\.(\*\.!??|\*\.part|INCOMPL\*|\[/\\\]INCOMPL\[^/\\\]\*\$|\\\.!??\$|\\\.part\$)\$" ;;
  music*) EXPR="${EXPR//\$)/)}${MATCH_ALL}\.(aif|aiff|flac|m4a|m4b|mp3|mpc|ogg|rm|voc|wav|wma)\$" ;;
  package*|pkg*) EXPR="${EXPR//\$)/)}${MATCH_ALL}\.(deb|rpm|tgz|txz)\$" ;;
  patch*|diff*) EXPR="${EXPR//\$)/)}${MATCH_ALL}\.(diff|patch)[^/]*$" ;;
  script*) EXPR="${EXPR//\$)/)}${MATCH_ALL}\.(bat|cmd|py|rb|sh)\$" ;;
  software*) EXPR="${EXPR//\$)/)}${MATCH_ALL}\.(\*\.msi|\*install\*\.exe|\*setup\*\.exe|\.msi|7z|deb|exe|install\*\.exe|msi|rar|rpm|setup\*\.exe|tar\.bz2|tar\.gz|tar\.xz|tbz2|tgz|txz|zip)\$" ;;
  source*) EXPR="${EXPR//\$)/)}${MATCH_ALL}\.(c|cpp|cxx|h|hpp|hxx)\$" ;;
  video*) EXPR="${EXPR//\$)/)}${MATCH_ALL}\.(3gp|avi|f4v|flv|m2v|mkv|mov|mp4|mpeg|mpg|ogm|vob|wmv)\$" ;;
  vmware*|vbox*|virt*|v*disk*|vdi*|qed*|qcow*|qemu*|vmdk*|vdisk*) EXPR="${EXPR//\$)/)}${MATCH_ALL}\.(vdi|vmdk|vhd|qed|qcow|qcow2|raw|vhdx|hdd)\$" ;;
  pdf|doc*) EXPR="${EXPR//\$)/)}${MATCH_ALL}\.(pdf|epub|mobi|azw3|djv|djvu)\$" ;;
  *book*|epub|mobi) EXPR="${EXPR//\$)/)}${MATCH_ALL}\.(epub|mobi|azw3|djv|djvu)\$" ;;
font*|truetype*) EXPR="${EXPR//\$)/)}${MATCH_ALL}\.(ttf|otf|bdf|pcf|fon|pfa|pfb|pt3|t42|sfd|otb|cff|cef|gai|woff|pf3|ttc|gsf|cid|dfont|mf|ik|fnt|pcf|pmf)\$" ;;
	'') ;;
  *) echo "No such class '$CLASS'." 1>&2; exit 2 ;;
esac

#MOUNT_OUTPUT=`mount`
#
#
#case "$OS" in
#  M[Ss][Yy][Ss]*)
#  (set -- /sysdrive/{a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}/; for DRIVE do test -d "$DRIVE" && exit 0; done; exit 1) && SYSDRIVE="/sysdrive" || unset SYSDRIVE 
#  MEDIAPATH="$SYSDRIVE/{a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}"
# ;;
#
#  Cygwin* | *cygwin*) CYGDRIVE="/cygdrive" 
#: ${MEDIAPATH="$CYGDRIVE/{a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}"}
#;;
#*Linux*|*linux*) : ${MEDIAPATH="/m*/*/"} ;;
#esac
#
#case "$(command grep --help 2>&1)" in
#  *--color*) GREP_ARGS="$GREP_ARGS --color=auto" ;;
#esac
#
#case "$OS" in
#  Cygwin) DRIVEPREFIX="/cygdrive" ;;
#*) test -d "/sysdrive"  && DRIVEPREFIX="/sysdrive" ;;
#esac
#
#while read C1 C2 C3 C4 C5 C6; do
#  if [ "$C2" = on ]; then
#    case "$C3" in
#      /[a-z])
#        INDEXES=`for x in a b c d e f g h i j k l m n o p q r s t u v w x y z; do test -e $DRIVEPREFIX/$x/files.list && echo $DRIVEPREFIX/$x/files.list; done`
#        break
#      ;;
#    esac
#  fi
#done <<<"$MOUNT_OUTPUT"
#
#if [ "$OS" = Cygwin -o -n "$DRIVEPREFIX" ]; then
#        INDEXES=`for x in a b c d e f g h i j k l m n o p q r s t u v w x y z; do test -e $DRIVEPREFIX/$x/files.list && echo $DRIVEPREFIX/$x/files.list; done`
#fi
#
MEDIAPATH="{$(set -- $( df 2>/dev/null|sed -n '\|/sys$|d ;; \|/sys |d ;; \|/proc|d ;; \|/dev$|d ;; \|/run|d ;; s,^[A-Za-z]\?:\?[\\/]\?[^ ]*\s[^\\/]\+\s\([\\/]\)\(.*\),\1\2,p' | sort -u); IFS=","; echo "${*%/}")}"

FILEARG="\$INDEXES"
case "$MEDIAPATH" in
  *"}") FILEARG="${MEDIAPATH}/files.list" ;;
esac

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

CMD="grep $GREP_ARGS -H -E \"\$EXPR\" $FILEARG | $FILTERCMD"

[ "$MIXED_PATH" = true ] && CMD="$CMD | sed 's|^/cygdrive/\(.\)|\\1:|'"
[ -n "$LIST" -o -n "$SORT" ] && CMD="$CMD | xargs -d \"\$NL\" ls ${LIST:--l --time-style=+%s} -d --"
if [ -n "$SORT" ]; then
	case "$SORT" in
		time) SORTARG="6" ;;
		size) SORTARG="5" ;;
	esac
	CMD="$CMD | sort -n ${SORTARG:+-k$SORTARG}"

	[ -z "$LIST" ] && CMD="$CMD | cut_ls_l"
fi

[ "$DEBUG" = true ] && echo "Command is $CMD" 1>&2
eval "($CMD) 2>/dev/null" 
