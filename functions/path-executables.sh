path-executables()
{ 
    ( IFS=":;";
    for DIR in $PATH;
    do
        ( cd "$DIR";
        for FILE in *;
        do
            test -f "$FILE" -a -x "$FILE" && echo "$FILE";
        done );
    done ) 2> /dev/null
}
