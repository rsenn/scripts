hex2chr () 
{ 
    ( S="";
    for ARG in "$@";
    do
        S="$S\\x$ARG";
    done;
    echo -e "$S" )
}
