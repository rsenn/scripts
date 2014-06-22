http_head()
{
    ( HOST=${1%%:*};
    PORT=80;
    TIMEOUT=30;
    if [ "$HOST" != "$1" ]; then
        PORT=${1#$HOST:};
    fi;
    if type curl > /dev/null 2> /dev/null; then
        curl -q --head "http://$HOST:$PORT$2";
    else
        if type lynx > /dev/null 2> /dev/null; then
            lynx -head -source "http://$HOST:$PORT$2";
        else
            {
                echo -e "HEAD ${2} HTTP/1.1\r\nHost: ${1}\r\nConnection: close\r\n\r";
                sleep $TIMEOUT
            } | nc $HOST $PORT | sed "s/\r//g";
        fi;
    fi )
}
