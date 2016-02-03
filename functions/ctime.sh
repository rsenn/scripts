ctime()
{
    ( TS="+%s";
    while :; do
        case "$1" in
            +*)
                TS="$1";
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    NW="[^ ]\+";
    WS=" \+";
    E="^${NW}${WS}";
    E="$E${NW}${WS}";
    E="$E${NW}${WS}";
    E="$E${NW}${WS}";
    E="$E${NW}${WS}";
    E="$E\(${NW}\)${WS}";
    E="$E\(.*\)";
    [ $# -gt 1 ] && R="\2: \1" || R="\1";
    ls --color=auto --color=auto --color=auto -l -n -d --time=ctime --time-style="${TS}" "$@" | ${SED-sed} "s/$E/$R/" )
}
