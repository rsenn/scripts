disk-size()
{
    ( while :; do
        case "$1" in
            -m | -M)
                DIV=1024;
                shift
            ;;
            -g | -G)
                DIV=1048576;
                shift
            ;;
            -k | -K)
                DIV=1;
                shift
            ;;
            -b | -B)
                MUL=1024;
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    R=$(sfdisk -s "$1");
    echo $(( R * ${MUL-1} / ${DIV-1} )) )
}
