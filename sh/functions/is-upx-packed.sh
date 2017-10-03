is-upx-packed()
{
    list-upx "$1" | ${GREP-grep} -q "\->.*$1"
}
