neighbours()
{
    while test "${2+set}" = set; do
        echo "$1" ${2+"$2"};
        shift;
    done
}
