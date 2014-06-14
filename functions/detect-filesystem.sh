detect-filesystem()
{
    if [ -e "$1" ]; then
        filesystem-for-device "$(device-of-file "$1")";
    fi
}
