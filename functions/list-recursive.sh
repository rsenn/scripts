list-recursive()
{ 
    ( NL="
";
    unset ARGS;
    while :; do
        case "$1" in 
            -s | -save)
                SAVE=true;
                shift
            ;;
            -a | -o | -maxdepth | -amin | -atime | -cnewer | -fstype | -group | -iname | -iwholename | -links | -mmin | -name | -path | -wholename | -uid | -user | -fprintf | -fprint | -exec | -ok | -execdir)
                ARGS="${ARGS:+$ARGS$NL}$1${NL}$2";
                shift 2
            ;;
            -print | -and | -follow | -depth | -mount | --version | -ignore_readdir_race | -N | -false | -nogroup | -readable | -executable | -type | -delete | -print | -prune)
                ARGS="${ARGS:+$ARGS$NL}$1";
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    [ $# = 0 ] && set .;
    for ARG in "$@";
    do
        ( cd "$ARG";
        CMD='find . $ARGS -xdev  | while read -r FILE; do test -d "$FILE" && echo "$FILE/" || echo "$FILE"; done | sed -u "s|^\.\/||"';
        [ "$SAVE" = true ] && CMD="$CMD | { tee .${FILENAME:-files}.${TMPEXT:-tmp}; mv -f .${FILENAME:-files}.${TMPEXT:-tmp} ${FILENAME:-files}.${EXT:-list}; echo \"Created \$PWD/${FILENAME:-files}.${EXT:-list}\" 1>&2; }";
        eval "$CMD" );
    done )
}
