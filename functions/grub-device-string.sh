grub-device-string()
{
    ( 
    
   grubdisk=$(lookup-grub-devicemap "$1")    
   if [ -n "$grubdisk" ]; then
	  device_number=${grubdisk#?hd}
	  device_number=${device_number%")"}
	else
    device_number=` disk-device-number "$1" `;
    fi
    
    
    
    partition_number=` disk-partition-number "$1" `;
    [ "$partition_number" ] && partition_number=$((partition_number-1));
    echo "(hd${device_number}${partition_number:+,${partition_number}})" )
}
