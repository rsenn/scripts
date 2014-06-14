filter-cmd()
{
    ( IFS="
";
    CMD="$*";
    while read -r LINE; do
        ( case "$CMD" in
            *{}*)
                EXEC=${CMD//"{}"/"$LINE"};
                EVAL="\$EXEC || exit \$?"
            ;;
            *)
                EXEC="$CMD";
                EVAL="\$EXEC \"\$LINE\" || exit \$?"
            ;;
        esac;
        case "$EXEC" in
            *\ *)
                EVAL="$EXEC"
            ;;
            *)

            ;;
        esac;
        eval "$EVAL" ) || break;
    done )
}
