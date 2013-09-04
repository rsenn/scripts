list-files()
{ 
    ( OUTPUT=">";
    OUTFILE=".files.file.tmp";
    while :; do
        case "$1" in 
            -v)
                OUTPUT="| tee ";
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    [ $# = 0 ] && set .;
    NL="
";
    FILTER="xargs -d \"\$NL\" file | sed -u \"s|^\.\/|| ;; s|:\s\+|: |\" ${OUTPUT}\"\${OUTFILE}\"";
    for ARG in "$@";
    do
        ( cd "$ARG";
        find . -xdev -not -type d | eval "$FILTER";
        mv -f .files.file.tmp files.file;
        echo "Created $PWD/files.file" 1>&2 );
    done )
}
