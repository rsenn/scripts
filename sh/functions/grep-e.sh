grep-e()
{
  NL="
"
    (IFS="
";  unset ARGS;
    eval "LAST=\"\${$#}\"";
    if [ ! -d "$LAST" ]; then
        unset LAST;
    else
        A="$*"; A="${A%$LAST}";
        set -- $A;
    fi;
    while [ $# -gt 0 ]; do
        case "$1" in
            --) shift; LAST="$*"; break ;;
            -*) ARGS="${ARGS+$ARGS$IFS}$1"; shift ;;
            *) WORDS="${WORDS+$WORDS$IFS}$1"; shift ;;
        esac;
    done;
    ${GREP-grep${NL}-a${NL}--line-buffered${NL}--color=auto} -E $ARGS "$(grep-e-expr $WORDS)" ${LAST:+$LAST} )
}
