myrealpath()
{ 
 (for ARG; do
    DIR=` dirname "$ARG" `;
    BASE=` basename "$ARG" `;
    cd "$DIR";
    if [ -h "$BASE" ]; then
    FILE=` readlink "$BASE"`;
    fi;
    DIR=` dirname "$FILE"`;
    BASE=`basename "$FILE"`;
    if is-relative "$ARG"; then
    DIR="$PWD/$DIR";
    fi;
    DIR=$(cd "$DIR"; pwd -P);
    echo "$DIR/$BASE"
  done)
}
