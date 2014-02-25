fstentry()
{ 
    ( DEV="$1" TYPE=${2-auto} OPTS=${3-defaults};
    MNT=/media/${DEV##*/};
    blkvars "$DEV";
    echo -e "UUID=$UUID\t$MNT\t\t$TYPE\t$OPTS\t0 0" )
}
