grep-e-expr()
{
  [ $# -gt 0 ] && exec <<<"$*"

  ${SED-sed} 's,[().*?|\\+],\\&,g ; s,\[,\\[,g ; s,\],\\],g' | implode "|" | ${SED-sed} 's,.*,(&),'
}
