unescape-newlines() {
  ${SED-sed} -e '\|\\$| {
  :lp
  N
  \|\\$| b lp
  s,\\\n\s*,,g
  }' "$@"
}
