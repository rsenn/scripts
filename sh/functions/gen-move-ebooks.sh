gen-move-ebooks () 
{ 
    for F in "$@";
    do
        BASEDIR=$(echo "$F"|sed "s|\(.*Books[^/]*\)/.*|\1|i ; s|\(.*Calibre[^/]*\)/.*|\1|i");
        RELPATH=${F#$BASEDIR/};
        echo "mkdir -p 'G:/Books/${RELPATH%/*}'; mv -vf '$F' 'G:/Books/${RELPATH%/*}'";
    done
}
