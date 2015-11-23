uuid-hexnums()
{
    getuuid "$1" | ${SED-sed} "s,[0-9A-Fa-f][0-9A-Fa-f], ${2:-0x}&,g" | ${SED-sed} "s,^\s*,, ; s,\s\+,\n,g"
}
