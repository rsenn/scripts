#!/bin/bash

locate_sources()
{
    (IFS="
 "; EXTS="c cpp cxx h hpp hxx"

 locate -i -r '.*' |grep -iE "\.($(IFS='| '; set -- $EXTS; echo "$*"))\$"
 )
}

locate_sources "$@"
