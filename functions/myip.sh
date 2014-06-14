myip()
{
    ( IFS=" " e_ip="[0-9]\\+\\.[0-9]\\+\\.[0-9]\\+\\.[0-9]\\+" e_nn="[^0-9]*";
    for host in ${@:-$INET_getip_hosts};
    do
        msg "Checking $host...";
        myip=$(curl -s --socks5 127.0.0.1:9050 "$host" |
         sed -n -e "/${e_nn}127.0.0.1${e_nn}/ d"                   -e "/${e_nn}192.168\./ d"                   -e "/${e_nn}10\./ d"                   -e "/$e_ip/ {
                      s|^${e_nn}\\($e_ip\\)${e_nn}\$|\\1|
                      p
                      q
                    }");
        if ip4_valid "$myip"; then
            echo "$myip";
            exit 0;
        fi;
    done;
    exit 1 )
}
