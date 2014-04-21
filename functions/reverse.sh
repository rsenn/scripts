reverse()
{ 
    ( INDEX=$#;
    while [ "$INDEX" -gt 0 ]; do
        eval "echo \"\${$INDEX}\"";
        INDEX=`expr $INDEX - 1`;
    done )
}
