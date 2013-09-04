unpackable()
{ 
    case $(mime $1) in 
        'application/x-tar')
            return 0
        ;;
        'application/x-zip')
            return 0
        ;;
    esac;
    return 1
}
