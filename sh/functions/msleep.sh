msleep()
{
    local sec=$((${1:-0} / 1000)) msec=$((${1:-0} % 1000));
    while [ "${#msec}" -lt 3 ]; do
        msec="0$msec";
    done;
    sleep $((sec)).$msec
}
