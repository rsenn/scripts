splitrev () { 
   (IFS=${1-" "};
    S=${IFS%"${IFS#?}"};
    R=${2-"$S"}
    while read -r LINE; do
        set -- $LINE;
        OUT=;
        for F in "$@"; do
            OUT="$F${OUT:+$R$OUT}";
            shift
        done
        echo "$OUT"
    done)
}
