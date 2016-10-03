#!/bin/bash

locate_books()
{
    (IFS="
 "; EXTS="pdf epub mobi azw3 djv djvu"

 locate -i -r '.*' |grep -iE "\.($(IFS='| '; set -- $EXTS; echo "$*"))\$"
 )
}

locate_books "$@"
