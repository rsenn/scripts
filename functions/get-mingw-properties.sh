get-mingw-properties() {
(unset PROPS
 while [ $# -gt 0 ]; do 
   case "$1" in 
     *[-/\\.]*) break ;; 
     --) shift; break ;;
     *) IFS="
 " pushv PROPS "$1"; shift ;;
   esac
 done
 if [ -z "$PROPS" ]; then
   IFS="
" pushv PROPS ARCH BITS DATE EXCEPTIONS MACH REV RTVER SNAPSHOT THREADS VER XBITS SUBDIR EXE VERN DRIVE
 fi
echo "PROPS:" $PROPS 1>&2
 for ARG; do   
  (NOVER=${ARG%%-[0-9]*}
   VER=${ARG#"$NOVER"}
   VER=${VER#[!0-9]}
#  VER=${VER%%[/\\]*}
#  VER=${VER%%-[a-z]*}
   IFS="-${IFS}/\\"
   unset BITS DATE EXCEPTIONS MACH REV RTVER SNAPSHOT THREADS VER VERNUM VERSTR XBITS
   set -- $ARG
   while [ $# -gt 0 ]; do 
   #echo "+ $1 $2" 1>&2
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
	  mingw | w64 | mingwbuilds) ;;
       mingw32 | mingw64) ;;
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

    VER="${1}${REV:+r$REV}${DATE:+d$DATE}${RTVER:+-rt$RTVER}"
    shift 
    VER="$VER${*:+-$*}"
    #set VERSTR="$VERSTR" 
    #echo "ARCH='$ARCH'${BITS:+ BITS='$BITS'}${DATE:+ DATE='$DATE'}${EXCEPTIONS:+ EXCEPTIONS='$EXCEPTIONS'}${MACH:+ MACH='$MACH'}${REV:+ REV='$REV'}${RTVER:+ RTVER='$RTVER'}${SNAPSHOT:+ SNAPSHOT='$SNAPSHOT'}${THREADS:+ THREADS='$THREADS'}${VER:+ VER='$VER'}${XBITS:+ XBITS='$XBITS'}"
    var_s=" "  var_dump ${PROPS} VERSTR VERNUM
  )
  done)
}
