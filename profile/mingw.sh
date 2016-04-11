conf_mingw() {
  unset prefix
  for CCPATH in /mingw*/bin/gcc; do
    target=$("$CCPATH" -dumpmachine)
    target=${target%$'\r'}    
    case "$target" in
      *-mingw*) prefix="${CCPATH%%/bin*}"; break ;;
    esac
  done
  if [ -n "$prefix" -a -d "$prefix" ]; then
    [ -n "$host" ] && build="$host"
    host="$target"
    builddir="build/$host"
    pathmunge -f "$prefix/bin"
    export CC="gcc" CXX="g++"
    unset PKG_CONFIG_PATH; init_pkgconfig_path
  fi
}