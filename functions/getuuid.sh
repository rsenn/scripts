getuuid()
{
    blkid "$@" | sed -n "/UUID=/ { s,.*UUID=\"\?,, ;; s,\".*,, ;; p }"
}
