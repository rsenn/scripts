blksize()
{ 
    ( SIZE=`fdisk -s "$1"`;
    [ -n "$SIZE" ] && expr "$SIZE" \* 512 / ${2-512} )
}
