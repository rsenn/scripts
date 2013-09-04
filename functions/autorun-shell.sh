autorun-shell()
{ 
   (EXEC="$1"
     shift
     [ $# -le 0 ] && set -- $(echo "$EXEC" |sed 's,Start,Start , ; s,\.exe,,g')
    echo "Shell\\Option1=$*
Shell\\Option1\\Command=$EXEC
")
}
