num-suffix () 
{ 
    ( for N in "$@";
    do
        if [ "$N" -ge 1099511627776 ]; then
            N=$(multiply-num "$N / 1099511627776")P;
        else
            if [ "$N" -ge 1073741824 ]; then
                N=$(multiply-num "$N / 1073741824")G;
            else
                if [ "$N" -ge 1048576 ]; then
                    N=$(multiply-num "$N / 1048576")M;
                else
                    if [ "$N" -ge 1024 ]; then
                        N=$(multiply-num "$N / 1024")K;
                    fi;
                fi;
            fi;
        fi;
        echo "$N";
    done )
}
