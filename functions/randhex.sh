randhex()
{
    for n in $(seq 1 ${1:-16});
    do
        printf "${2:-0x}%02x\n" $((RANDOM % 256 ));
    done
}
