hex2chr()
{ 
    echo "puts -nonewline [format \"%c\" 0x$1]" | tclsh
}
hex2chr () 
{ 
    ( S="";
    for ARG in "$@";
    do
        S="$S\\x$ARG";
    done;
    echo -e "$S" )
}
