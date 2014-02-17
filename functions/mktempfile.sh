mktempfile()
{ 
    local prefix=${2-${tmppfx-${myname-${0##*/}}}};
    local path=${1-${tmpdir-"/tmp"}};
    command mktemp ${path:-"-t" }"${path:+/}${prefix#-}.XXXXXX"
}
