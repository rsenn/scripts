list-visual-studios() {
 (NL="
"
  IFS="$NL"
  SP=" "
  while :; do
    case "$1" in
      -c | -cl | --cl | --compiler) pushv O "CL" ; shift ;;
      -b | -vsdir | --vsdir) pushv O "VSDIR" ; shift ;;
      -d | -vcdir | --vcdir) pushv O "VCDIR" ; shift ;;
      -v | -vcvars | --vcvars) pushv O "VCVARS"; shift ;;
      -e | -devenv | --devenv) pushv O "DEVENV"; shift ;;
      -t | -tool | --tool) pushv T "$2"; pushv O "TOOL_$2"; shift 2 ;; -t=* | -tool=* | --tool=*) pushv T "${1#*=}"; pushv O "TOOL_${1#*=}"; shift ;;
      -p | -pathconv | --pathconv) PATHCONV="$2";  shift 2 ;; -p=* | -pathconv=* | --pathconv=*) PATHCONV="${1#*=}"; shift ;;
      -t*) pushv T "${1#-?}"; pushv O "TOOL_${1#-t}"; shift ;;

      *) break ;;
    esac
  done
  : ${PATHCONV="cygpath$NL-w"}
  PATHCONV=${PATHCONV//" "/"$NL"}

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
    
    
    DEVENV="$VSDIR/Common7/IDE/devenv"
    
    #echo "VSDIR: $VSDIR VSVER: $VSVER" 1>&2
   VSNAME="Visual Studio $(vc2vs "${VSVER}")${ARCH:+ $ARCH}"
   for VAR in $O; do
     eval "\${PATHCONV:-echo} \"\${$VAR}\""
   done
  done
  
  )
}
