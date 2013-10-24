getuuid()
{ 
    blkid "$@" | sed -n "/UUID=/ { s,.*UUID=\"\?,,; s,\".*,,; s,-,,g ; p}"
}
