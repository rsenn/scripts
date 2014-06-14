grub-device-string()
{
    ( device_number=` disk-device-number "$1" `;
    partition_number=` disk-partition-number "$1" `;
    [ "$partition_number" ] && partition_number=$((partition_number-1));
    echo "(hd${device_number}${partition_number:+,${partition_number}})" )
}
