unpack-deb()
{ 
    ( for ARG in "$@";
    do
        ( TMPDIR=` mktemp -d `;
        trap 'rm -rf "$TMPDIR"' EXIT;
        ARG=` realpath "$ARG"`;
        DIR=${DESTDIR-"$PWD"};
        DEST="$DIR"/$(basename "$ARG" .deb);
        cd "$TMPDIR";
        ar x "$ARG";
        mkdir -p "$DEST";
        tar -C "$DEST" -xf data.tar.gz;
        [ "$?" = 0 ] && echo "Unpacked to $DEST" 1>&2 );
    done )
}
