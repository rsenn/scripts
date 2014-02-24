match()
{ 
    case $1 in 
        $2)
            return 0
        ;;
        *)
            return 1
        ;;
    esac
}
