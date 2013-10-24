uuid_hexnums()
{ 
    getuuid "$1" | sed "s,[0-9A-Fa-f][0-9A-Fa-f], ${2:-0x}&,g" | sed "s,^\s*,, ; s,\s\+,\n,g"
}
