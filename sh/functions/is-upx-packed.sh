is-upx-packed()
{
  NL="
"
    list-upx "$1" | ${GREP-grep${NL}-a${NL}--line-buffered${NL}--color=auto} -q "\->.*$1"
}
