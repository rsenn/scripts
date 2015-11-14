get-exts () 
{ 
    ( eval "$(sed -n 's|.*EXTS="\([^"]*\)".*|EXTS="\1"|p' "$1" )";
    IFS="$IFS ";
    set -- $EXTS;
    echo "$*" )
}
