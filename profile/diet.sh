conf-diet() {
  case "$1" in
    dyn) DIET="diet-dyn" ;;
    *) DIET="diet" ;;
  esac
  CC="${DIET} ${CC##*${DIET} }"
  CXX="${DIET} ${CXX##*${DIET} }"
  CFLAGS=${CFLAGS/-march=*\ /}
  CFLAGS=${CFLAGS/-mtune=*\ /}
  CFLAGS=${CFLAGS//-msse[0-9]/}
  CFLAGS=${CFLAGS//-O?/}
  CFLAGS="-march=i486 -mtune=pentium4 -Os $CFLAGS"
  CXXFLAGS=${CXXFLAGS/-march=*\ /}
  CXXFLAGS=${CXXFLAGS/-mtune=*\ /}
  CXXFLAGS=${CXXFLAGS//-msse[0-9]/}
  CXXFLAGS=${CXXFLAGS//-O?/}
  CXXFLAGS="-march=i486 -mtune=pentium4 -Os $CXXFLAGS"

  pathmunge /opt/diet/bin after

  builddir="build/i486-linux-${DIET##*/}"
  export CC CFLAGS CXX CXXFLAGS builddir
}
