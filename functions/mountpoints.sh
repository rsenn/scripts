mountpoints()
{
    ( while :; do
        case "$1" in
            -u | --user)
                USER=true;
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    function lsmnt()
    {
        if [ -e /proc/mounts ]; then
            awk '{ print $2'"${1:+.\"/${1#/}\"} }" /proc/mounts;
        else
            if type df 2> /dev/null > /dev/null; then
                :;
            else
                ( IFS=" ";
                mount | while read -r DRIVE ON MNT TYPE USER OPTS; do
                    if [ -n "$MNT" -a -d "$MNT" ]; then
                        echo "$MNT${1:+/${1#/}}$";
                    fi;
                done );
            fi;
        fi
    };
    CMD="lsmnt \"\$@\"";
    [ "$USER" = true ] && CMD="$CMD | grep -vE '^(/\$|/proc|/sys|/dev)'";
    eval "$CMD" )
}
