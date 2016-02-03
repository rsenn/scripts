conf-clang() {
  CC="clang"
  CXX="clang++"

  case "$builddir" in
	   */*-gnu) builddir=${builddir%-gnu}-clang ;;
        *) builddir=$builddir-clang ;;
  esac

  export CC CXX builddir
}
