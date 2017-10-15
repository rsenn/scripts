list-devices-by () 
{ 
    ls --color=auto -d /dev/disk/by-label/* | for_each -f 'echo "$(readlink -f "$1"): LABEL=\"${1##*/}\""';
    ls --color=auto -d /dev/disk/by-uuid/* | for_each -f 'echo "$(readlink -f "$1"): UUID=\"${1##*/}\""'
}
