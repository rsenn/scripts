pkg-search() {
	for arg; do 
    pkg search "$arg" 2>/dev/null | pacman-joinlines | sed '/^Checking\b/d; /^Sorting\b/d; /^Full Text\b/d; /^\[/d;  pkg-search,^\([^ /]*\)/\([^ ]*\),\1,'
  done | (IFS=" $IFS"; while read -r NAME VER ARCH _ REST; do
    printf "%-40s %-8s  %-7s  %pkg-search\n" "$NAME" "$VER" "$ARCH" "$REST"
  done)
}
