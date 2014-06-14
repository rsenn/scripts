is-relative()
{
    case "$1" in
        /*)
            return 1
        ;;
        *)
            return 0
        ;;
    esac
}
