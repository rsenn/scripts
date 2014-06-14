mktempdata()
{
    local path prefix="${tmppfx-${myname-${0##*/}}}" file;
    if [ "$#" -gt 1 ]; then
        path=$1;
        shift;
    else
        unset path;
    fi;
    if [ "$#" -gt 1 ]; then
        local prefix=$1;
        shift;
    fi;
    file=`command ${path:-"-t"} "${path:+$path/}${prefix#-}${path:-.XXXXXX}"`;
    if [ -n "$*" ]; then
        echo "$*" > $file;
    fi;
    echo "$file"
}
