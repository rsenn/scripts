device-of-file()
{ 
    ( for ARG in "$@";
    do
        ( if [ -e "$ARG" ]; then
            if [ -L "$ARG" ]; then
                ARG=`myrealpath "$ARG"`;
            fi;
            if [ -b "$ARG" ]; then
                echo "$ARG";
                exit 0;
            fi;
            if [ ! -d "$ARG" ]; then
                ARG=` dirname "$ARG" `;
            fi;
            DEV=`(grep -E "^[^ ]*\s+$ARG\s" /proc/mounts ;  df "$ARG" |sed '1d' )|awkp 1|head -n1`;
            [ $# -gt 1 ] && DEV="$ARG: $DEV";
            echo "$DEV";
        fi );
    done )
}
