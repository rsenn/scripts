usleep()
{ 
    local sec=$((${1:-0} / 1000000)) usec=$((${1:-0} % 1000000));
    while [ "${#usec}" -lt 6 ]; do
        usec="0$usec";
    done;
    sleep $((sec)).$usec
}
