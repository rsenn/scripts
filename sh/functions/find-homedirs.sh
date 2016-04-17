find-homedirs()
{
  NL="
"
 (locate32.sh /home/ |
  ${SED-sed} 's|/home/\([^/]\+\).*|/home/\1|'|uniq
find-media.sh '/home/[^/]+/$'|removesuffix / ) |
  ${GREP-grep${NL}-a${NL}--line-buffered${NL}--color=auto} -vE '(/include/|/usr/)' |
   filter-test -d
}

