grep-e()
{ 
    ( unset ARGS;
    eval "LAST=\"\${$#}\"";
    if [ ! -d "$LAST" ]; then
        unset LAST;
    else
        A="$*";
        A="${A%$LAST}";
        set -- $A;
    fi;
    while :; do
        case "$1" in 
            -*)
                ARGS="${ARGS+$ARGS
	}$1";
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    grep --color=auto --color=auto --color=auto -E $ARGS "$(grep-e-expr "$@")" ${LAST:+"$LAST"} )
}
