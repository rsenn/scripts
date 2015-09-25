list-visual-studios() {
 (while :; do
    case "$1" in
      -c | -cl | --cl | --compiler) O=CL ; shift ;;
      -b | -vsdir | --vsdir) O=VSDIR ; shift ;;
      -d | -vcdir | --vcdir) O=VCDIR ; shift ;;
      -v | -vcvars | --vcvars) O=VCVARS; shift ;;
      -t | -tool | --tool) O=TOOL_$2; shift 2 ;;
      -t=* | -tool=* | --tool=*) O=TOOL_${1#*=}; shift ;;
      -t*) O=TOOL_${1#-t}; shift ;;


      *) break ;;
    esac
  done
#  : ${O=VSNAME}
  set -- "$($PATHTOOL "${ProgramFiles:-$PROGRAMFILES}")"{," (x86)"}/*Visual\ Studio\ [0-9]*/VC/bin/{,*/}cl.exe
  ls -d -- "$@" 2>/dev/null |sort -V | while read -r CL; do
    case "$CL" in
      *amd64/*) ARCH="Win64" ;;
      *arm/*) ARCH="ARM" ;;
      *ia64/*) ARCH="IA64"   ;;
      *) ARCH="" ;;
    esac
    
    
    TARGET=${CL##*/bin/}; TARGET=${TARGET%%cl.exe}; TARGET=${TARGET%/}
    #: ${TARGET:="x86"}
    
    VSDIR="${CL%%/VC*}"	
    VCDIR="$VSDIR/VC"
    VCVARS="call \"$($PATHTOOL -w "$VSDIR/VC/vcvarsall.bat")\"${TARGET:+ $TARGET}"
    VSVER=${VSDIR##*/}
    VSVER=${VSVER##*"Visual Studio "}
    
    #echo "VSDIR: $VSDIR VSVER: $VSVER" 1>&2
   VSNAME="Visual Studio $(vc2vs "${VSVER}")${ARCH:+ $ARCH}"
   eval "echo \"\${$O:-\$VSNAME}\""
  done
  
  )
}
