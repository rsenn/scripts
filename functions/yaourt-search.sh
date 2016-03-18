yaourt-search () 
{ 
    ( for Q in "$@";
    do
        ( IFS=" $IFS";
        yaourt -Ss $Q | yaourt-joinlines $OPTS | grep --colour=auto -i -E "$(grep-e-expr $Q)" );
    done )
}
