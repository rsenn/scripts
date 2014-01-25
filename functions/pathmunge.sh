pathmunge()
{ 
    local IFS=":";
    : ${OS=`uname -o`};
    case "$OS:$1" in 
        [Mm]sys:*[:\\]*)
            tmp="$1";
            shift;
            set -- `msyspath "$tmp"` "$@"
        ;;
    esac;
    if ! echo "$PATH" | egrep -q "(^|:)$1($|:)"; then
        if test "$2" = "after"; then
            PATH="$PATH:$1";
        else
            PATH="$1:$PATH";
        fi;
    fi
}
