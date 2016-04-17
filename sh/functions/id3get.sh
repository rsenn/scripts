id3get()
{
  NL="
"
    ( id3dump "$1" 2>&1 | ${GREP-grep${NL}-a${NL}--line-buffered${NL}--color=auto} "^$2" | ${SED-sed} 's,^[^:=]*[:=]\s*,,' )
}
