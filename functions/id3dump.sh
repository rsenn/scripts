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
    id3v2 $FLAGS --list-rfc822 "$@" | sed -u -n 's,^\([^ ]\+\) ([^:]\+): \(.*\),\1=\2,p' )
}
