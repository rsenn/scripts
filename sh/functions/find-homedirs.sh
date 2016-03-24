find-homedirs() {
 (locate32.sh /home/ |
  ${SED-sed} 's|/home/\([^/]\+\).*|/home/\1|'|uniq
find-media.sh '/home/[^/]+/$'|removesuffix / ) |
  ${GREP-grep} -vE '(/include/|/usr/)' |
   filter-test -d
}

