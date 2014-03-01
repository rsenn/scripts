removesuffix()
{ 
    ( SUFFIX=$1;
    shift;
    echo "${*%%$SUFFIX}" )
}
