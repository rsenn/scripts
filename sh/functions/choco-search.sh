choco-search () 
{ 
    ( IFS=" $IFS${nl}";
    while [ $# -gt 0 ]; do
        ( set -x;
        choco search -f -v $1 ) | choco-joinlines | ( set -- ${GREP:-grep
--color=yes} -i $1 --;
        eval "$*" );
        shift;
    done )
}
