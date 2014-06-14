mime()
{
    local mime="$(decompress "$1" | bheader 8 | file -bi -)";
    echo ${mime%%[,. ]*}
}
