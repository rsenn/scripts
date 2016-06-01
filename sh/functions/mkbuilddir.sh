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
    : ${T=}
    P="$2"
    case "$1" in
      *64*) : ${T:="x64"} ;;
      *) : ${T:="Win32"} ;;
    esac
    case "$1" in
      *2008* | *9.0*) echo "vcbuild \"${P/vcxproj/vcproj}\"${3:+ \"$3${T:+|$T}\"}" ;;
      *) echo "msbuild \"${P}\"${3:+ /p:Configuration=\"$3\"}" ;;
    esac
  }
  while :; do
    case "$1" in
      -x | --debug) DEBUG="true"; shift ;;
      -64 | --64 | -x64 | --x64 | -amd64 | --amd64 | -x86_64 | --x86_64) ARCH="amd64" ;;
      *) break ;;
    esac
  done
  
  for ARG; do
   (case "$ARG" in
       *.sln) VC=$(sln-version --vc "$ARG"); DIR=$(dirname "$ARG") ;;
       *) VC=$(vs2vc "${ARG##*/}") ; DIR="$ARG" ;;
    esac
    
    [ "$DEBUG" = true ] && debug "VC version: $VC"
   
    B=$(basename "$DIR")
    
   
    CL=$(vcget "$VC" CL)
    CMAKEGEN=$(vcget "$VC" CMAKEGEN)
    : ${ARCH=$(vcget "$B" ARCH)}
    VSA=${VS-$(vcget "$VC" VS)}${ARCH:+-$ARCH}
    ABSDIR=$(cd "$DIR" >/dev/null && pwd -P)
    SRCDIR=${ABSDIR%/build*}
	if [ -e "$SRCDIR/CMakeLists.txt" ] ; then
	  CMAKELISTS="$SRCDIR/CMakeLists.txt"
      CMAKELISTS_ADD=$( ${SED-sed} -n "s|.*add_subdirectory(\s*\([^ )]*\)\s*).*|$SRCDIR/\1/CMakeLists.txt|p"  "$SRCDIR/CMakeLists.txt" )
	  if [ -n "$CMAKELISTS_ADD" ]; then
		pushv_unique CMAKELISTS $CMAKELISTS_ADD
	  fi
	  PROJECT=$(${SED-sed} -n   's|.*project\s*(\s*\([^ )]\+\).*|\1|ip' "$SRCDIR/CMakeLists.txt")
	  CONFIGURE_CMD="
cmake -G \"$(vcget "$VC" CMAKEGEN)\"$ARGS ^
  %* ^
  ..\\..
"	  
	  BUILD_TYPE="RelWithDebInfo MinSizeRel Debug Release"
	else
	  SOLUTION=$(cd "$DIR" >/dev/null && ls -d *.sln)
	fi
    PREFIX="${SRCDIR##*/}\\${DIR##*/}"
    [ -n "$INSTALLROOT" ] && INSTALLROOT=$(${PATHTOOL:-echo} "$INSTALLROOT")
    if [ -n "$CMAKELISTS" ]; then
	  if [ -z "$INSTALLROOT" ] && ${GREP-grep
-a
--line-buffered
--color=auto} -q -i "add_library\s*(" $CMAKELISTS ; then
		case "$SRCDIR" in
		  *-[0-9]*) INSTDIR=${SRCDIR##*/} ;;
		  *) INSTDIR=${SRCDIR##*/}-$(isodate.sh -r "$SRCDIR") ;;
		esac
		  INSTALLROOT="E:/Libraries/${INSTDIR}/${B}"
	  fi
	  if ${GREP-grep
-a
--line-buffered
--color=auto} -q -i "install\s*(" $CMAKELISTS ; then
		INSTALL_CMD=$(output_vcbuild "$B" INSTALL.vcxproj "Release")
	  fi
	  add_def CMAKE_INSTALL_PREFIX "${INSTALLROOT:-%PROGRAMFILES%\\$PREFIX}"
	  add_def CMAKE_VERBOSE_MAKEFILE "TRUE"
	  for VAR in BUILD_SHARED_LIBS ENABLE_SHARED; do
	   if ${GREP-grep
-a
--line-buffered
--color=auto} -q "$VAR" $CMAKELISTS ; then
	   add_def $VAR "TRUE"
	   fi
	  done
	  if [ -n "$__BUILD_TYPE" ]; then
		add_def CMAKE_BUILD_TYPE "$BUILD_TYPE"
	  fi
	fi
  if [ -z "$ARCH" ]; then
	pushv ARGS_LOOP 'for %%T in (Win32 x86) do if /I "%1" == "%%T" ('${nl}'  set TARGET=Win32'${nl}'  set ARCH=x86'${nl}'  shift'${nl}'  goto :args'${nl}')'
	pushv ARGS_LOOP 'for %%T in (Win64 x64 AMD64) do if /I "%1" == "%%T" ('${nl}'  set TARGET=x64'${nl}'  set ARCH=amd64'${nl}'  shift'${nl}'  goto :args'${nl}')'
	pushv IF_TARGET 'if "%TARGET%" == "" set TARGET=Win32'
	pushv IF_TARGET 'if "%ARCH%" == "" set ARCH=x86'
	 T="%TARGET%"
   else
	#IF_TARGET="if not \"%1\" == \"\" set ARGS=/target:\"%1\"${nl}"
	ADD_ARGS=" %ARGS%"
  fi
	VCBUILDCMD=$(output_vcbuild "$(vcget "$VC" VS ARCH)" ${SOLUTION:-$PROJECT.sln} %%G)
    pushv ARGS_LOOP 'for %%C in (Debug Release) do if /I "%1" == "%%C" ('${nl}'  set CONFIG=%%C'${nl}'  shift'${nl}'  goto :args'${nl}')'
	pushv IF_TARGET 'if "%CONFIG%" == "" set CONFIG=Debug Release'
	case "$VCBUILDCMD" in
	  *vcbuild*)  pushv ARGS_LOOP 'for %%J in (clean rebuild) do if /I "%1" == "%%J" ('${nl}'  set ARGS= /%%J'${nl}'  shift'${nl}'  goto :args'${nl}')'  ;;
	  *)  pushv ARGS_LOOP 'for %%J in (clean rebuild) do if /I "%1" == "%%J" ('${nl}'  set ARGS= /t:%%J'${nl}'  shift'${nl}'  goto :args'${nl}')'  ;;
	esac
	ADD_ARGS=" %ARGS%"
	BUILD_TYPE="%CONFIG%"
	VCVARSCMD=$(vcget "${VC}-x64" VCVARSCMD )
	VCVARSCMD=${VCVARSCMD/amd64/%ARCH%}
	
	case "$VCBUILDCMD" in
	  *"
"*) VCBUILDCMD="(
$VCBUILDCMD
)" ;;
    esac
	
	if [ -e "$CL" ]; then
      echo "Generating script $DIR/build.cmd ($(vcget "$VC" VCNAME))" 1>&2
      unix2dos >"$DIR/build.cmd" <<EOF
@echo ${BATCHECHO:-off}
cd %~dp0
${ARGS_LOOP:+${nl}:args${nl}$ARGS_LOOP${nl}}${CONFIGURE_CMD:+${nl}$CONFIGURE_CMD${nl}}${IF_TARGET:+${nl}$IF_TARGET${nl}}${VCVARSCMD:+${nl}call $VCVARSCMD${nl}${BATCHECHO:+@echo $BATCHECHO${nl}}}
for %%G in (${BUILD_TYPE:-Debug Release}) do $VCBUILDCMD${ADD_ARGS}
${INSTALL_CMD}
EOF
    fi) || exit $?
  done)
}
