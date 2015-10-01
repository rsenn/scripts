var_get () {
 (while [ $# -gt 0 ]; do 
    eval "echo \"\$$1\""
   shift
  done)
}


get-mingw-properties() {
(unset PROPS
 : ${OUTCMD="var_get"}
  while [ $# -gt 0 ]; do 
   case "$1" in 
     -x | --debug) OUTCMD="var_dump"; DEBUG=true; shift ;;
     *[-/\\.]*) break ;; 
     --) shift; break ;;
     *) IFS="
 " pushv PROPS "$1"; shift ;;
   esac
 done
 if [ -z "$PROPS" ]; then
   IFS="
" pushv PROPS ARCH BITS DATE EXCEPTIONS MACH REV RTVER SNAPSHOT THREADS VER XBITS SUBDIR EXE VERN DRIVE VERSTR VERNUM TOOLCHAIN TARGET
 fi
[ "$DEBUG" = true ] && echo "PROPS:" $PROPS 1>&2
 for ARG; do   
  [ "$ARG" = -- ] && continue
  (
  [ "$DEBUG" = true ] && echo "ARG: $ARG" 1>&2
  NOVER=${ARG%%-[0-9]*}
   VER=${ARG#"$NOVER"}
   VER=${VER#[!0-9]}
#  VER=${VER%%[/\\]*}
#  VER=${VER%%-[a-z]*}
   IFS="${IFS:+-$IFS}/\\"
   unset BITS DATE EXCEPTIONS MACH REV RTVER SNAPSHOT THREADS VER VERNUM VERSTR XBITS
   set -- $ARG
   while [ $# -gt 0 ]; do 
   #[ "$DEBUG" = true ] && echo "+ $1 $2" 1>&2
     case "$1" in     
       *snapshot*) SNAPSHOT=$2; IFS="-" pushv VERNUM "snapshot$2"; shift; pushv VERSTR "snapshot$2" ;;
     rev?????? |rev????????) DATE="${1#rev}" ; pushv VERSTR "d$DATE" ;;
     rev*) REV="${1#rev}" ; pushv VERSTR "r$REV" ;;
       rt_v*) RTVER="${1#rt_v}"; pushv  VERSTR "rt$RTVER" ;;
       x86_64|x64|mingw64|amd64) BITS=64 ARCH=x86_64 MACH=x64 XBITS=x64 ;;
     i?86|x32|x86) BITS=32 ARCH=i686 MACH=x86 XBITS=x32 ;;
       seh) EXCEPTIONS=seh ;;
       sjlj) EXCEPTIONS=sjlj ;;
       posix) THREADS=posix ;;
       win32|w32) THREADS=win32 ;;
       dwarf|dw2) EXCEPTIONS=dw2 ;;
       #[0-9].[0-9]* |	 [0-9]*) VERNUM="$1"; pushv VERSTR "$VERNUM" ;;
       ???drive) DRIVE="$2"; shift  ;;
       ?:) DRIVE="${1%:}" ;;
       w64) MINGWTYPE=mingw-w64 ;;
	   mingwbuilds) MINGWTYPE=$1 ;;
	   cygwin | msys) MINGWTYPE=$1-cross ;;
       mingw32 | mingw64) MINGW=$1 ;;
       [Bb]in | [Ll]ib | [Ii]nclude) SUBDIR="$1" ;;
       [[:digit:]]*) VERN="$1"; pushv VERNUM "$1" ;;
       *.EXE | *.exe) EXE="${1}" ;;
       # *) IFS="-" pushv VERNUM "$1";  pushv VERSTR "$1" ;;
       "") ;;
       *) IFS="-" pushv VERNUM "$1";  pushv VERSTR "$1" ; echo "No such version str: '$1'" 1>&2 ;;
      esac
      shift
    done
    IFS="$IFS :-
"
   VERNUM=${VERNUM#[!0-9a-z]}
	set -- $VERNUM       
	while [ -z "$1" -a $# -gt 0 ]; do shift ; done
#	   [ -z "$MINGW" ] && MINGW="mingw${XBITS#x}"
    W64ID="${ARCH}-${1}${THREADS:+-$THREADS}${EXCEPTIONS:+-$EXCEPTIONS}${RTVER:+-rt_v$RTVER}${REV:+-rev$REV}"
    BUILDSID="${XBITS}-${1}${SNAPSHOT:+-snapshot-$SNAPSHOT}${DATE:+-rev$DATE}${THREADS:+-$THREADS}${EXCEPTIONS:+-$EXCEPTIONS}"
    if [ "$MINGWTYPE" = mingw-w64 ]; then
      TOOLCHAIN=${W64ID}
    elif [ "$MINGWTYPE" = mingwbuilds ]; then
      TOOLCHAIN=${BUILDSID}
    fi
    TARGET="${ARCH}-${MINGW:-mingw${1//./}${REV:+r$REV}${RTVER:+-rt$RTVER}}${THREADS:+-$THREADS}${EXCEPTIONS:+-$EXCEPTIONS}"
    VER="${1}${REV:+r$REV}${DATE:+d$DATE}${RTVER:+-rt$RTVER}"
    shift 
    VER="$VER${*:+-$*}"
    #set VERSTR="$VERSTR" 
    #echo "ARCH='$ARCH'${BITS:+ BITS='$BITS'}${DATE:+ DATE='$DATE'}${EXCEPTIONS:+ EXCEPTIONS='$EXCEPTIONS'}${MACH:+ MACH='$MACH'}${REV:+ REV='$REV'}${RTVER:+ RTVER='$RTVER'}${SNAPSHOT:+ SNAPSHOT='$SNAPSHOT'}${THREADS:+ THREADS='$THREADS'}${VER:+ VER='$VER'}${XBITS:+ XBITS='$XBITS'}"
    var_s=" "  $OUTCMD ${PROPS}
  )
  done)
}
