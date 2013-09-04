myrealpath()
{ 
    ( DIR=` dirname "$1" `;
    BASE=` basename "$1" `;
    cd "$DIR";
    if [ -h "$BASE" ]; then
        FILE=` readlink "$BASE"`;
    fi;
    DIR=` dirname "$FILE"`;
    BASE=`basename "$FILE"`;
    if is-relative "$1"; then
        DIR="$PWD/$DIR";
    fi;
    DIR=$(cd "$DIR"; pwd -P);
    echo "$DIR/$BASE" )
}
