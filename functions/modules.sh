modules()
{
    local abs="no" ext="no" dir modules= IFS="
";
    require "fs";
    while :; do
        case $1 in
            -a)
                abs="yes"
            ;;
            -e)
                ext="yes"
            ;;
            -f)
                abs="yes" ext="yes"
            ;;
            *)
                break
            ;;
        esac;
        shift;
    done;
    if test "$abs" = yes; then
        fs_recurse "$@";
    else
        for dir in "${@-$shlibdir}";
        do
            ( cd "$dir" && fs_recurse );
        done;
    fi | {
        set --;
        while read module; do
            case $module in
                *.sh | *.bash)
                    if test "$ext" = no; then
                        module="${module%.*}";
                    fi;
                    if ! isin "$module" "$@"; then
                        set -- "$@" "$module";
                        echo "$module";
                    fi
                ;;
            esac;
        done
    }
}
