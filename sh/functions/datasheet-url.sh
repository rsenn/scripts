datasheet-url()
{
  NL="
"
    RESULTS=1000 google.sh "$1 datasheet filetype:pdf" | ${GREP-grep${NL}-a${NL}--line-buffered${NL}--color=auto} -i "$1[^/]*$"
}
