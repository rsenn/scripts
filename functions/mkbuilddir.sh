mkbuilddir() {
 (Q=\"
  FS=/
  BS=\\	
  add_def() {
    V=$1
    shift
    old_IFS="$IFS"
    IFS=";"
    ARGS="$ARGS ^
  -D $V=${Q}${*//$FS/$BS}${Q}"
    IFS="$old_IFS"
    unset old_IFS
  }
  
  # output_vcbuild <target> <Project|Solution> [Configuration]
  output_vcbuild() {
    T=
    P="$2"
    case "$1" in
      *64*) T="x64" ;;
      *x86*) T="Win32" ;;
    esac
    case "$1" in
      *2008* | *9.0*) echo "vcbuild ${P/vcxproj/vcproj}${3:+ \"$3${T:+|$T}\"}" ;;
      *) echo "msbuild ${P}${3:+ /p:Configuration=\"$3\"}" ;;
    esac
  }
  
  for DIR; do
   (B=$(basename "$DIR")

    CL=$(vcget "$B" CL)
    CMAKEGEN=$(vcget "$B" CMAKEGEN)
  
    ARCH=$(vcget "$B" ARCH)

    ABSDIR=$(cd "$DIR" >/dev/null && pwd -P)
    SRCDIR=${ABSDIR%/build*}
    
    CMAKELISTS="$SRCDIR/CMakeLists.txt"

    CMAKELISTS_ADD=$( sed -n "s|.*add_subdirectory(\s*\([^ )]*\)\s*).*|$SRCDIR/\1/CMakeLists.txt|p"  "$SRCDIR/CMakeLists.txt" )
    if [ -n "$CMAKELISTS_ADD" ]; then
      pushv_unique CMAKELISTS $CMAKELISTS_ADD
    fi

    PROJECT=$(sed -n   's|.*project\s*(\s*\([^ )]\+\).*|\1|ip' "$SRCDIR/CMakeLists.txt")

    PREFIX="${SRCDIR##*/}\\${DIR##*/}"
    
    [ -n "$INSTALLROOT" ] && INSTALLROOT=$(${PATHTOOL:-echo} "$INSTALLROOT")

    if [ -z "$INSTALLROOT" ] && grep -q -i "add_library\s*(" $CMAKELISTS ; then
	  case "$SRCDIR" in
		*-[0-9]*) INSTDIR=${SRCDIR##*/} ;;
		*) INSTDIR=${SRCDIR##*/}-$(isodate.sh -r "$SRCDIR") ;;
      esac
		INSTALLROOT="E:/Libraries/${INSTDIR}/${B}"
    fi

    if grep -q -i "install\s*(" $CMAKELISTS ; then
      INSTALL_CMD=$(output_vcbuild "$B" INSTALL.vcxproj "Release")
    fi
    
	add_def CMAKE_INSTALL_PREFIX "${INSTALLROOT:-%PROGRAMFILES%\\$PREFIX}"
    add_def CMAKE_VERBOSE_MAKEFILE "TRUE"
    
	for VAR in BUILD_SHARED_LIBS ENABLE_SHARED; do
	 if grep -q "$VAR" $CMAKELISTS ; then
	 add_def $VAR "TRUE"
	   
	 fi
	done

    if [ -n "$__BUILD_TYPE" ]; then
      add_def CMAKE_BUILD_TYPE "$BUILD_TYPE"
    fi

    if [ -e "$CL" ]; then
      echo "Generating script $DIR/build.cmd ($(vcget "$B" VCNAME))" 1>&2
      unix2dos >"$DIR/build.cmd" <<EOF
@echo off

call $(vcget "$B" VCVARSCMD)

cd %~dp0

cmake -G "$(vcget "$B" CMAKEGEN)"$ARGS ^
  %* ^
  ..\\..

if not "%1"=="" set ARGS=/target:"%1"

for %%G in (${BUILD_TYPE:-RelWithDebInfo MinSizeRel Debug Release}) do $(output_vcbuild "$B" $PROJECT.sln %%G)
${INSTALL_CMD}
EOF
    fi) || exit $?
  done)
}