tempnam()
{
    local IFS=" $newline";
    local pfx=${0##*/};
    local prefix=${2-${tmppfx-${pfx%:*}}};
    local path=${1-${tmpdir-"/tmp"}};
    local name=`command mktemp -u ${path:-"-t" }"${path:+/}${prefix#-}.XXXXXX"`;
    rm -rf "$name";
    echo "$name"
}
