mminfo()
{
    ( for ARG in "$@";
    do
        minfo "$ARG" | ${SED-sed} -n "s,^\([^:]*\):\s*\(.*\),${2:+$ARG:}\1=\2,p";
    done | ${SED-sed} \
        's,\s\+=,=,  ;;
s|\([0-9]\) \([0-9]\)|\1\2|g
/Duration/ { 
  s|\([0-9]\) min|\1min|g
  s|\([0-9]\) \([hdw]\)|\1\2|g
  s|\([0-9]\) \(m\?s\)|\1\2|g
  s|\([0-9]\+\) \([^ ]*b/s\)$|\1\2|
}')
}
