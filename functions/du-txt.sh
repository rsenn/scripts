du-txt()
{ 
    ( IFS="
";
    TMP="du.tmp$RANDOM";
    echo -n > "$TMP";
    trap 'rm -f "$TMP"' EXIT;
    CMD='du -x -s -- ${@-*} |sort -n -k1';
    if [ -w "$TMP" ]; then
        CMD="$CMD | (tee \"\$TMP\"; mv -f \"\$TMP\" du.txt; echo \"Saved list into du.txt\" 1>&2)";
    fi;
    eval "$CMD" )
}
