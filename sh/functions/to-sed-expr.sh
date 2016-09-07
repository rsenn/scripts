to-sed-expr()
{
 ([ $# -gt 0 ] && exec <<<"$*"
  ${SED-sed} 's|[.*\\]|\\&|g ;; s|\[|\\[|g ;; s|\]|\\]|g')
}
