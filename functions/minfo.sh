minfo()
{ 
    timeout ${TIMEOUT:-10} mediainfo "$@" 2>&1 | sed 's,\s*:,:, ; s, pixels$,, ; s,: *\([0-9]\+\) \([0-9]\+\),: \1\2,g'
}
