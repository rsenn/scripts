aspect()
{ 
    ( case "$#" in 
        1)
            W="${1%%x*}" H="${1#*x}"
        ;;
        2)
            W="$1" H="$2"
        ;;
    esac;
    GCD=$(gcd "$W" "$H");
    echo "$((W / GCD)):$((H / GCD))" )
}
