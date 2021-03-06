vcget() {
echo "vcget \"$1\" $2" 1>&2
  case "$1" in
	*2005* | *2008* | *2010* | *2012* | *2013* | *2015*)
	  VC=$(vs2vc -0 "$1")
	  VS=$(vc2vs "$VC")
      ARCH=${1##*$VS}
      
	;;
	  *)
	  VS=$(vc2vs "$1")
	  VC=$(vs2vc -0 "$VS")
      ARCH=${1##*${VC%.*}-}
	;;
  esac
  : ${ARCH:=x86}
  ARCH=${ARCH#[!0-9A-Za-z_]}
  CMAKE_ARCH=
  case "$ARCH" in
   amd64|x64) ARCH="amd64" CMAKE_ARCH="Win64" ;;
  esac
  
  case "$ARCH" in
    amd64|amd64_arm|amd64_x86|arm|ia64|x86_amd64|x86_arm|x86_ia64) ARCHDIR="$ARCH" ;;
    *) ARCHDIR= ;;
  esac
  
echo "CMAKE_ARCH=$CMAKE_ARCH" 1>&2

  shift

  VSINSTALLDIR="${PROGRAMFILES% (x86)}${ProgramW6432:+ (x86)}\\Microsoft Visual Studio $VC"
  VCINSTALLDIR="$VSINSTALLDIR\\VC"
  BINDIR="$VCINSTALLDIR\\bin${ARCHDIR:+\\$ARCHDIR}"
  CL="$BINDIR\\cl.exe"
  DevEnvDir="$VCINSTALLDIR\\Common7\\IDE"
  DEVENV="$DevEnvDir\\devenv.exe"
  BITS=${ARCHDIR##*[!0-9]}

#echo "ARCH=$ARCH" 1>&2

  VCVARSALL="$VCINSTALLDIR\\vcvarsall.bat"

  case "$VC" in
    9.0) VCVARSARCH="$BINDIR\\vcvars${ARCHDIR:-32}.bat" ;;
    *) VCVARSARCH="$BINDIR\\vcvars${BITS:-32}.bat" ;;
  esac

  VCVARSCMD="\"$VCVARSALL\" ${ARCH:-x86}"

  VCNAME="Microsoft Visual Studio $VC${ARCHDIR:+ ($ARCHDIR)}"
  CMAKEGEN="Visual Studio ${VC%.0*} ${VS}" #${CMAKE_ARCH:+ $CMAKE_ARCH}"

   VSVARS="${ARCHDIR:+$VCVARSARCH}"
   : ${VSVARS:="$VSINSTALLDIR\\Common7\\Tools\\vsvars32.bat"}

  WindowsSdkDir=$(cmd /c 'reg query "HKLM\SOFTWARE\Microsoft\Microsoft SDKs\Windows" /v "CurrentInstallFolder"' | ${SED-sed} -n "s|.*REG_SZ\s\+||p")

  local $(${GREP-grep
-a} -i -E "^\s*@?set \"?(INCLUDE|LIB|LIBPATH|FrameworkDir|FrameworkVersion|Framework35Version)=" "$VSVARS" | ${SED-sed} \
   -e "s,.*set \"\?\([^\"]\+\)\"\?,\1,i" \
   -e "s|%VCINSTALLDIR%|${VCINSTALLDIR//"\\"/"\\\\"}|g" \
   -e "s|%VSINSTALLDIR%|${VSINSTALLDIR//"\\"/"\\\\"}|g" \
   -e "s|%WindowsSdkDir%|${WindowsSdkDir//"\\"/"\\\\"}|g")

  case "$ARCHDIR" in
    *amd64*) CMAKEGEN="$CMAKEGEN Win64" ;;
  esac

  [ $# -eq 0 ] && set -- VCINSTALLDIR

  for VAR; do
    eval "O=\$$VAR"
#    echo "O=\"$O\"" 1>&2
    case "$O" in
      *\;*) echo "$O" ;;
      ?:\\*) ${PATHTOOL:-echo} "$O" ;;
      *) echo "$O" ;;
    esac
  done
}
