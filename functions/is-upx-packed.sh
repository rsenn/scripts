is-upx-packed()
{
    list-upx "$1" | ${GREP-grep} --color=auto --color=auto --color=auto -q "\->.*$1"
}
