detect-system() {
  case ${MACHINE:=`uname -m`} in
    *64) BITS=64 ;;
    *) BITS=32 ;;
  esac
  case `which gcc` in
    */mingw*/bin/gcc*) SYS=$(which gcc); SYS=${SYS%%/bin*}; SYS=${SYS##*/} ;;
    *)  case ${OS:=`uname -o`} in
		  [Mm][Ss][Yy][Ss]*) 
			ROOT=`cygpath -am /`
			SYS=`basename "${ROOT}"`
			
			;;
		  *) SYS=`uname -o | tr "[[:upper:]]" "[[:lower:]]"`
		   ;;
		esac
	  ;;
  esac
  SYS=${SYS%%[36][24]*}
  SYS=${SYS//"-"/""}
  echo "$SYS$BITS"
}