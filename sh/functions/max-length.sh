max-length () 
{ 
    ( max=$1;
    shift;
    a=$*;
    l=${#a};
    [ $((l)) -gt $((max)) ] && a="${a:1:$((max - 3))}...";
    echo "$a" )
}
