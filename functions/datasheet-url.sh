datasheet-url() {
    RESULTS=1000 google.sh "$1 datasheet filetype:pdf" | ${GREP-grep} --color=auto --line-buffered -i "$1[^/]*$"
}
