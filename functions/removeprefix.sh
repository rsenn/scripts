removeprefix()
{ 
    ( PREFIX=$1;
    shift;
    echo "${*##$PREFIX}" )
}
