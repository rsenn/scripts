cmake_args() {
 (for BUILDDIR; do
    sed -n '
    /-ADVANCED/d
    /-NOTFOUND/d
    /=$/d
    s|:[^=]*=\(.*\)|="\1"|p
  
  ' "$BUILDDIR"/CMakeCache.txt
  done)
}
