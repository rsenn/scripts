index_of()
{ 
    ( needle="$1";
    index=0;
    while [ "$#" -gt 1 ]; do
        shift;
        if [ "$needle" = "$1" ]; then
            echo "$index";
            exit 0;
        fi;
        index=`expr "$index" + 1`;
    done;
    exit 1 )
}
