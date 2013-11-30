id3dump()
{ 
    ( IFS="
	";
    unset FLAGS;
    while :; do
        case "$1" in 
            -*)
                FLAGS="${FLAGS+$FLAGS
	}$1";
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
		id3v2 $FLAGS  -l "$@" | sed -u -n 's, ([^:]*)\(\[[^]]*\]\)\?:\s\+,: , ;; s,^\([[:upper:][:digit:]]\+\):,\1:,p'
		)
}
