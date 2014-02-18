iso-extract()
{ 
    ( NAME=`basename "$1" .iso`;
    DEST=${2:-"$NAME"};
    7z x -o"$DEST" "$1" )
}
