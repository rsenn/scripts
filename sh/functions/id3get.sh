id3get()
{
    ( id3dump "$1" 2>&1 | ${GREP-grep} "^$2" | ${SED-sed} 's,^[^:=]*[:=]\s*,,' )
}
