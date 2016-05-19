mktempfile() {
   (prefix=${2-${tmppfx-${MYNAME-${0##*/}}}};
    path=${1-${TEMP-"/tmp"}};
    tempfile=${path}/${prefix#-}.${RANDOM}
    rm -f "$tempfile"
    echo -n >"$tempfile"
    echo "$tempfile")
}
