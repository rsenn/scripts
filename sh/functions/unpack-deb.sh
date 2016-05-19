unpack-deb()
{
    ( for ARG in "$@";
    do
        ( TEMP=` mktemp -d `;
        trap 'rm -rf "$TEMP"' EXIT;
        ARG=` realpath "$ARG"`;
        DIR=${DESTDIR-"$PWD"};
        DEST="$DIR"/$(basename "$ARG" .deb);
        cd "$TEMP";
        ar x "$ARG";
        mkdir -p "$DEST";
        tar -C "$DEST" -xf data.tar.gz;
        [ "$?" = 0 ] && echo "Unpacked to $DEST" 1>&2 );
    done )
}
