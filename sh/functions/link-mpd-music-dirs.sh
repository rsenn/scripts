link-mpd-music-dirs()
{
    ( : ${DESTDIR=/var/lib/mpd/music};
    mkdir -p "$DESTDIR";
    chown mpd:mpd "$DESTDIR";
    for ARG in "$@";
    do
        ( NAME=$(echo "$ARG" |${SED-sed} " s,^/mnt,, ; s,^/media,,g; s,/,-,g; s,^-*,, ; s,-*$,,");
        ( set -x;
        ln -svf "$ARG" "$DESTDIR"/"$NAME" ) );
    done )
}
