is-upx-packed()
{
    list-upx "$1" | ${GREP-grep -a --line-buffered --color=auto} -q "\->.*$1"
}
