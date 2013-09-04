disk-device-letter()
{ 
    DEV="$1";
    DEV=${DEV##*/};
    echo "${DEV:2:1}"
}
