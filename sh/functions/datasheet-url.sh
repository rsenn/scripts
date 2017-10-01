datasheet-url() {
    RESULTS=1000 google.sh "$1 datasheet filetype:pdf" | ${GREP-grep} -i "$1[^/]*$"
}
