mkzroot()
{
    ( IFS="$IFS "
 TEMPTAR=/tmp/mkzroot$$.tar;    
 TEMPTXZ=${TEMPTAR%.tar}.txz
    trap 'rm -vf "$TEMPTAR" "$TEMPTXZ"' EXIT INT QUIT;
    EXCLUDE="*~ *.tmp *mnt/* *.log *cache/*";
    CMD='tar --one-file-system --exclude={$(IFS=", $IFS"; set -f ; set -- $EXCLUDE;  echo "$*")} -C /root -cf "$TEMPTAR" .';
    CMD=$CMD'; xz -3 -vfcn "$TEMPTAR" >"$TEMPTXZ"'
    eval "echo \"+ $CMD\" 1>&2";
    eval "$CMD";
    DEST=$(ls -d ` mountpoints /pmagic/pmodules ` 2>/dev/null);
    for DIR in $DEST;
    do
        ( CMD="cp --remove-destination -vf  \"\$TEMPTXZ\"  \"\$DIR/zroot.xz\"";
        eval "echo \"+ $CMD\" 1>&2";
        eval "$CMD" );
    done )
}
