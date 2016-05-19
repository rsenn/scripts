cut-distver()
{
  cat "$@" | ${SED-sed} 's,\.fc[0-9]\+\(\.\)\?,\1,g'
}
