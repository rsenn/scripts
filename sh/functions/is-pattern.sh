is-pattern()
{
    case "$*" in
        *'['*']'* | *'*'* | *'?'*)
            return 0
        ;;
    esac;
    return 1
}
