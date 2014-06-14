bpm()
{
    ( unset NAME;
    if [ $# -gt 1 ]; then
        NAME=":";
    fi;
    for ARG in "$@";
    do
        BPM=` id3v2 -l "$ARG" |sed -n 's,TBPM[^:]*:\s*,,p' `;
        echo "${NAME+$ARG: }${BPM%.*}";
    done )
}
