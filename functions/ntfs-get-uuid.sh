ntfs-get-uuid()
{
    ( IFS=" ";
    set -- $(  dd if="$1" bs=1 skip=$((0x48)) count=8 |hexdump -C -n8);
    IFS="";
    echo "${*:2:8}" )
}
