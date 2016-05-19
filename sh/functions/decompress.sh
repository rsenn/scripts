decompress()
{
    local mime="$(file -bi "$1")";
    case $mime in
        application/x-bzip2)
            bzip2 -dc "$1"
        ;;
        application/x-gzip)
            gzip -dc "$1"
        ;;
        *)
            cat "$1"
        ;;
    esac
}
