juce-mingw-build() { 
 (: ${MSYS_HOME="e:/msys64"}
  : ${MINGW_HOME="$MSYS_HOME/mingw64"}
  unset VARS TARGETS DIRS
  while [ $# -gt 0 ]; do
    ARG="$1"; shift
    if [ -d "$ARG" ]; then
      pushv DIRS "$ARG"
      continue
    fi    
    case "$ARG" in
      *=*) pushv VARS "$ARG"; continue ;;
      *) pushv TARGETS "$ARG" ;;
    esac    
  done 
  [ -z "$DIRS" ] && DIRS=.
  var_dump VARS DIRS TARGETS
  export PKG_CONFIG_PATH="$(cygpath -a "${MINGW_HOME}"/*/pkgconfig | implode :)" PKG_CONFIG_SYSROOT_DIR="$(cygpath -am "${MSYS_HOME}")"

  for P in $DIRS; do 
    DIR=${P%/Builds*}
	P=$DIR/Builds/MinGW*
    (cd "$DIR"
     set -- *.jucer; J="$1"
	  for JUCER in {Pro,Intro}jucer; do (set -x; $JUCER --resave "$J") && {
	   $JUCER --add-exporter "MinGW Makefile" "$J" 
	 }
  set -x; make -C Builds/MinGW*  $VARS $TARGETS && exit 0
	done) || exit $?
	
  done)
}

