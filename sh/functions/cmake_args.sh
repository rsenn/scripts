cmake_args() {
 (for BUILDDIR; do
    sed -n 's|:[^=]*=\(.*\)|="\1"|p' "$BUILDDIR"/CMakeCache.txt
  done)
}
