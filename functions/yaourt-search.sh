yaourt-search () 
{ 
    ( for Q in "$@";
    do
        ( IFS="| $IFS"; set -- $Q
				yaourt -Ss $@ | yaourt-joinlines $OPTS | grep --colour=auto -i -E "($*)" );
    done )
}
