datasheet-url() {
    RESULTS=1000 google.sh "$1 datasheet filetype:pdf" | ${GREP-grep
-a
--line-buffered
--color=auto} -i "$1[^/]*$"
}
