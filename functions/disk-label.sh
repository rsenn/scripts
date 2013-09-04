disk-label()
{ 
    ( DEV=${1};
    test -L "$DEV" && DEV=` myrealpath "$DEV"`;
    cd /dev/disk/by-label;
    find . -type l | while read -r LINK; do
        TARGET=`readlink "$LINK"`;
        if [ "${DEV##*/}" = "${TARGET##*/}" ]; then
            NAME=${LINK##*/};
            case "$NAME" in 
                *[[:lower:]]*)
                    LOWER=true
                ;;
            esac;
            if [ "$LOWER" = true -o ! -r "$LINK" ]; then
                echo -e "$NAME";
            else
                FS=` filesystem-for-device "$DEV"`;
                case "$FS" in 
                    *fat)
                        IFS="
";
                        set -- $(dosfslabel "$LINK");
                        test $# = 1 && echo "$1"
                    ;;
                    *)
                        echo -e "$NAME"
                    ;;
                esac;
            fi;
            exit 0;
        fi;
    done;
    exit 1 )
}
