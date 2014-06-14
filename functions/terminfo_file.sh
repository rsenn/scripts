terminfo_file()
{
    ( for ARG in "$@";
    do
        F="/usr/share/terminfo/`firstletter "$ARG"`/$ARG";
        test -e "$F" && echo "$F" || {
            echo "$F not found" 1>&2;
            exit 1
        };
    done )
}
