get-prefix() {
  ${CC:-gcc} -print-search-dirs | sed -n \
  's,.*:\s\+=\?,,; s,/\+,/,g; s,/bin.*,,p ; s,/lib.*,,p ' | head -n1
}
