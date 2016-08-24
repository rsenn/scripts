disk-partition-number()
{
    DEV="$1";
    DEV=${DEV##*/};
    echo "${DEV:3:1}"
}
