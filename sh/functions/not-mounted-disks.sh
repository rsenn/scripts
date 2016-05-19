not-mounted-disks()
{
    ( IFS="
";
    for DISK in $(all-disks);
    do
        is-mounted "$DISK" || echo "$DISK";
    done )
}
