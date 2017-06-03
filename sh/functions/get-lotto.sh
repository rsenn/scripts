get-lotto() {
    dl-lotto() {
		eval "set -- http://www.mylottoy.net/de/lotto-schweiz/lottozahlen/6aus45/lottozahlen-{`Y=$(date +%Y); seq -s, $((Y)) -1 $((Y-5))`}.asp"
		
			for_each -f -x 'lynx -source "$1"' "$@"
		}
    CMD='dl-lotto'
    if [ -n "$1" -a -e "$1" ]; then
      CMD='cat "$@"'
    fi
    eval "$CMD" | sed "s|<div class='span-30'>|\n&|gp" | grep --color=auto --line-buffered --text span-30 | \
    sed -n '/ den / { s,<[^>]*>,;,g ; s,([^)]*),,g ; s,\&nbsp;, ,g; s,;\s\+,;,g; s,\s\+:\s\+,:,g; s,;\+,;,g; s,:;,: ,g ; s,^;,, ; s,;$,, ;  s|\([[:upper:]][[:lower:]]\)[a-z]* den |\1, | ; p }'  |
    sed 's,\([0-9]\):\([0-9]\),\1 \2,g ; s,\([0-9]\):\([0-9]\),\1 \2,g ; s|;\([0-9]\) |; \1 | ;
    s,\([0-9]\) \([0-9]\) ,\1  \2 ,g ; s,\([0-9]\) \([0-9]\) ,\1  \2 ,g' |
    sed 's,: \([0-9]\)\([; ]\),:  \1\2,g' |
    sed 's,Replay:\s\+\([0-9]\)$,Replay:  \1,' |
    sed 's,\([A-Za-z]\+:\s\+[0-9]\+\);\([A-Za-z]\+:\s\+[0-9]\+\),\1 \2,g ; s,\([A-Za-z]\+:\s\+[0-9]\+\);\([A-Za-z]\+:\s\+[0-9]\+\),\1 \2,g' |
    sed 's|;|\t|g' |
    sed 's|\(..............\)\s\(.................\)\s\(......\)\s\(........\)|\1\t\2\t\3\t\4|'
}
