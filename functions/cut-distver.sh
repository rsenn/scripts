cut-distver()
{
  cat "$@" | sed 's,\.fc[0-9]\+\(\.\)\?,\1,g'
}
