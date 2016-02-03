is-var()
{
    case $1 in
        [!_A-Za-z]* | *[!_0-9A-Za-z]*)
            return 1
        ;;
    esac;
    return 0
}
