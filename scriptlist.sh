#!/bin/bash

IFS="
"

list() 
{ 
   (TAB="	" EOL="\\"
    [ $# -gt 1 ] && echo " $EOL"
    while [ "$1" ]; do
      [ $# -eq 1 ] && EOL=""
      echo "${TAB}$1${EOL:+ $EOL}"
      shift
    done)
}

set -- *.{sh,awk,fontforge,bash,pl,py,rb,el}

list `echo "$*" | sort -u | grep -v '^\*\.'` 
