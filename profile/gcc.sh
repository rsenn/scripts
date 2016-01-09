conf-gcc() {
  CC="gcc"
  CXX="g++"

  case "$builddir" in
	  *-clang*) builddir=${builddir%%-clang*}-gnu ;;
  esac

  export CC CXX builddir
}
