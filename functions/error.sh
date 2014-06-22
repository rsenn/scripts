error()
{
    local retcode="${2:-1}";
    msg "ERROR: $@";
    if [ "$0" = "-sh" -o "${0##*/}" = "sh" -o "${0##*/}" = "bash" ]; then
        return "$retcode";
    else
        exit "$retcode";
    fi
}
