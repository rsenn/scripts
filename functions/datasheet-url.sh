datasheet-url () 
{ 
    RESULTS=1000 google.sh "$1 transistor filetype:pdf" | /bin/grep --color=auto --line-buffered -i "$1[^/]*$"
}
