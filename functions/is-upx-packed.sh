is-upx-packed()
{
    list-upx "$1" | grep --color=auto --color=auto --color=auto -q "\->.*$1"
}
