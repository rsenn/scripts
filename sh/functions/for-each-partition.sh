for-each-partition()
{
    ( SCRIPT="$1";
    shift;
    blkid "$@" | while read -r LINE; do
        DEV=${LINE%%": "*};
        VALUES=${LINE#*": "};
        ( eval "$VALUES";
        eval "$SCRIPT" );
    done )
}
