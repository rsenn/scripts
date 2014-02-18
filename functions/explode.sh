explode()
{ 
    ( IFS="$2$IFS";
    for VALUE in $1;
    do
        echo "$VALUE";
    done )
}
