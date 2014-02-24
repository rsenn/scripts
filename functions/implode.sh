implode()
{ 
    ( unset DATA;
    while read LINE; do
        DATA="${DATA+$DATA$1}$LINE";
    done;
    echo "$DATA" )
}
