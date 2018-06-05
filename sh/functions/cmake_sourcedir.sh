cmake_sourcedir() {
 (for BUILDDIR; do
    sed -n '
    /^CMAKE_SOURCE_DIR/!d 
    s|^[^=]*=||p
  
  ' "$BUILDDIR"/CMakeVars.txt
  done)
}

