id3get()
{
    ( id3dump "$1" 2>&1 | ${GREP-grep -a --line-buffered --color=auto} "^$2" | ${SED-sed} 's,^[^:=]*[:=]\s*,,' )
}
