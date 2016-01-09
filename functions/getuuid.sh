getuuid()
{
    blkid "$@" | ${SED-sed} -n "/ UUID=/ { s,.* UUID=\"\?,, ;; s,\".*,, ;; p }"
}
