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
c2w() 
{ 
    ch_conv UTF-8 UTF-16 "$@"
}
w2c() 
{ 
    ch_conv UTF-16 UTF-8 "$@"
}
