#!/bin/bash

cygpath () 
{ 
	(IFS="
"
    while :; do
        case "$1" in 
            -*)
                shift
            ;;
            *)
                break
            ;;
        esac;
    done;
    echo "$*")
}

cygpath "$@"
