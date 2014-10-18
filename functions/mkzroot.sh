mkzroot()
{
    ( IFS="$IFS " TEMPTAR=/tmp/mkzroot$$.tar;
    trap 'rm -vf "$TEMPTAR"' EXIT INT QUIT;
    EXCLUDE="*~ *.tmp *mnt/* *.log *cache/*";
    CMD='tar --one-file-system --exclude={$(IFS=", $IFS"; set -f ; set -- $EXCLUDE;  echo "$*")} -C /root -cf "$TEMPTAR" .';
    eval "echo \"+ $CMD\" 1>&2";
    eval "$CMD";
    DEST=$(ls -d ` mountpoints /pmagic/pmodules ` 2>/dev/null);
    for DIR in $DEST;
    do
      case "$DIR" in
        /mnt/*/mnt/*) continue ;;
      esac
        ( CMD="xz -1  -c <\"\$TEMPTAR\"  >\"\$DIR/zroot.xz\"";
        eval "echo \"+ $CMD\" 1>&2";
        eval "$CMD" );
    done )
}
