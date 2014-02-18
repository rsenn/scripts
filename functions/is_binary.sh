is_binary()
{ 
    case `file - <$1` in 
        *text*)
            return 1
        ;;
        *)
            return 0
        ;;
    esac
}
