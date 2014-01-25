gcd()
{ 
    ( A="$1" B="$2";
    while :; do
        if [ "$A" = 0 ]; then
            echo "$B" && break;
        fi;
        B=$((B % A));
        if [ "$B" = 0 ]; then
            echo "$A" && break;
        fi;
        A=$((A % B));
    done )
}
