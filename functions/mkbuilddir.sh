mkbuilddir() {
 (Q=\"
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

    PROJECT=$(sed -n   's|.*project\s*(\s*\([^ )]\+\).*|\1|p' "$SRCDIR/CMakeLists.txt")

 

    PREFIX="${SRCDIR##*/}\\${DIR##*/}"

    [ -n "$INSTALLROOT" ] && INSTALLROOT=$(${PATHTOOL:-echo} "$INSTALLROOT")

    if [ -z "$INSTALLROOT" ] && grep -q -i add_library $CMAKELISTS ; then
	  case "$SRCDIR" in
		*-[0-9]*) INSTDIR=${SRCDIR##*/} ;;
		*) INSTDIR=${SRCDIR##*/}-$(isodate.sh -r "$SRCDIR") ;;
      esac
		INSTALLROOT="E:/Libraries/${INSTDIR}/${B}"
    fi

    if [ -e "$CL" ]; then
      echo "Generating script $DIR/build.cmd ($(vcget "$B" VCNAME))" 1>&2
      unix2dos >"$DIR/build.cmd" <<EOF
@echo off

call $(vcget "$B" VCVARSCMD)

cd %~dp0

cmake -G "$(vcget "$B" CMAKEGEN)" ^
  -D CMAKE_INSTALL_PREFIX="${INSTALLROOT:-%PROGRAMFILES%\\$PREFIX}" ^
  -D CMAKE_VERBOSE_MAKEFILE="TRUE" ^
${__BUILD_TYPE:+  -D CMAKE_BUILD_TYPE=${Q}$BUILD_TYPE${Q} ^
} ..\\..

if not "%1"=="" set ARGS=/target:"%1"

for %%G in (${BUILD_TYPE:-RelWithDebInfo MinSizeRel Debug Release}) do msbuild $PROJECT.sln /p:Configuration="%%G" %ARGS%
EOF
    fi) || exit $?
  done)
}