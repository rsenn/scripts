rcat()
{
    local opts= args=;
    while test -n "$1"; do
        case $1 in
            *)
                pushv args "$1"
            ;;
            -*)
                pushv opts "$1"
            ;;
        esac;
        shift;
    done;
    grep --color=auto --color=auto --color=auto --color=no $opts '.*' $args
}
