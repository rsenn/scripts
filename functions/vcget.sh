vcget() {
  case "$1" in
	*2005* | *2008* | *2010* | *2012* | *2013* | *2015*)
	  VC=$(vs2vc -0 "$1")
	  VS=$(vc2vs "$VC")
      ARCH=${1#*$VS}
	;;
	  *)
	  VS=$(vc2vs "$1")
	  VC=$(vs2vc -0 "$VS")
      ARCH=${1#*$VC}
	;;
  esac
  ARCH=${ARCH#[!0-9A-Za-z_]}
  case "$ARCH" in
    x64) ARCH="amd64" ;;
    amd64|amd64_arm|amd64_x86|arm|ia64|x86_amd64|x86_arm|x86_ia64) ;;
    *) ARCH= ;;
  esac

  shift

  VSINSTALLDIR="${PROGRAMFILES% (x86)}${ProgramW6432:+ (x86)}\\Microsoft Visual Studio $VC"
  VCINSTALLDIR="$VSINSTALLDIR\\VC"
  BINDIR="$VCINSTALLDIR\\bin${ARCH:+\\$ARCH}"
  CL="$BINDIR\\cl.exe"
  DevEnvDir="$VCINSTALLDIR\\Common7\\IDE"
  DEVENV="$DevEnvDir\\devenv.exe"

  BITS=${ARCH##*[!0-9]}


  VCVARSALL="$VCINSTALLDIR\\vcvarsall.bat"

  case "$VC" in
    9.0) VCVARSARCH="$BINDIR\\vcvars${ARCH:-32}.bat" ;;
    *) VCVARSARCH="$BINDIR\\vcvars${BITS:-32}.bat" ;;
  esac

  VCVARSCMD="\"$VCVARSALL\" ${ARCH:-x86}"

  VCNAME="Microsoft Visual Studio $VC${ARCH:+ ($ARCH)}"
  CMAKEGEN="Visual Studio ${VC%.0*} ${VS}"

   VSVARS="${ARCH:+$VCVARSARCH}"
   : ${VSVARS:="$VSINSTALLDIR\\Common7\\Tools\\vsvars32.bat"}

  WindowsSdkDir=$(reg query "HKLM\SOFTWARE\Microsoft\Microsoft SDKs\Windows" /v "CurrentInstallFolder" | sed -n "s|.*REG_SZ\s\+||p")

  local $(grep -i -E "^\s*@?set \"?(INCLUDE|LIB|LIBPATH|FrameworkDir|FrameworkVersion|Framework35Version)=" "$VSVARS" | sed \
   -e "s,.*set \"\?\([^\"]\+\)\"\?,\1,i" \
   -e "s|%VCINSTALLDIR%|${VCINSTALLDIR//"\\"/"\\\\"}|g" \
   -e "s|%VSINSTALLDIR%|${VSINSTALLDIR//"\\"/"\\\\"}|g" \
   -e "s|%WindowsSdkDir%|${WindowsSdkDir//"\\"/"\\\\"}|g")

  case "$ARCH" in
    *amd64*) CMAKEGEN="$CMAKEGEN Win64" ;;
  esac

  [ $# -eq 0 ] && set -- VCINSTALLDIR

  for VAR; do
    eval "O=\$$VAR"
    case "$O" in
      *\;*) echo "$O" ;;
      ?:\\*) ${PATHTOOL:-echo} "$O" ;;
      *) echo "$O" ;;
    esac
  done
}