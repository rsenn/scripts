is_url()
{
    case $1 in
        *://*)
            return 0
        ;;
        *)
            return 1
        ;;
    esac
}
