is-object()
{
    case `file - <$1` in
        *ELF* | *executable*)
            return 0
        ;;
        *)
            return 1
        ;;
    esac
}
