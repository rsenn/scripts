find-homedirs() {
 (locate32.sh /home/ |
  sed 's|/home/\([^/]\+\).*|/home/\1|'|uniq
find-media.sh '/home/[^/]+/$'|removesuffix / ) |
  grep -vE '(/include/|/usr/)' |
   filter-test -d
}

