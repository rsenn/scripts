pushv_unique()
{ 
    local v=$1 s IFS=${IFS%${IFS#?}};
    shift;
    for s in "$@";
    do
        if eval "! isin \$s \${$v}"; then
            pushv "$v" "$s";
        else
            return 1;
        fi;
    done
}
