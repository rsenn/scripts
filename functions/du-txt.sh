du-txt()
{
    ( IFS="
";
    TMP="du.tmp$RANDOM";
    echo -n > "$TMP";
    trap 'rm -f "$TMP"' EXIT;
    CMD='(du -x -s -- ${@-$(ls-dirs)})';
    if [ -w "$TMP" ]; then
        CMD="$CMD | (tee \"\$TMP\"; sort -n -k1 <\"\$TMP\" >du.txt; rm -f \"\$TMP\"; echo \"Saved list into du.txt\" 1>&2)";
    fi;
    eval "$CMD" )
}
