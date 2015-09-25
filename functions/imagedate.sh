imagedate()
{
        (
        case "$1" in
                 -u | --unix*) UT=true ; shift ;;
         esac
        N=$#
         for ARG; do
        TS=$(exiv2 pr "$ARG" 2>&1| sed -n '/No\sExif/! s,.*timestamp\s\+:\s\+,,p' | sed 's,\([0-9][0-9][0-9][0-9]\):\([0-9]\+\):\([0-9][0-9]\),\1/\2/\3,')
        [ "$UT" = true ] && TS=$(date2unix "$TS" 2>/dev/null)
        O="$TS"

        [ $N -gt 1 ] && O="$ARG:$O"
        echo "$O"
    done)
}
