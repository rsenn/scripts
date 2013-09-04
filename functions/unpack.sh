unpack()
{ 
    case $(mime "$1") in 
        application/x-tar)
            tar ${2+-C "$2"} -xf "$1" && return 0
        ;;
        application/x-zip)
            unzip -L -qq -o ${2+-d "$2"} "$1" && return 0
        ;;
    esac;
    return 1
}
