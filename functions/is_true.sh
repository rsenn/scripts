is_true()
{ 
    case "$*" in 
        true | ":" | "${FLAGS_TRUE-0}" | yes | enabled | on)
            return 0
        ;;
    esac;
    return 1
}
