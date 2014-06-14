ch_conv()
{
    FROM="$1" TO="$2";
    shift 2;
    for ARG in "$@";
    do
        ( trap 'rm -f "$TMP"' EXIT;
        TMP=$(mktemp);
        iconv -f "$FROM" -t "$TO" <"$ARG" >"$TMP" && mv -vf "$TMP" "$ARG" );
    done
}
