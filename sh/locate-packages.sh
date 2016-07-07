#!/bin/bash

locate_packages()
{
    (IFS="
 "; EXTS="rpm deb txz tgz"

 locate -i -r '.*' |grep -iE "\.($(IFS='| '; set -- $EXTS; echo "$*"))\$"
 )
}

locate_packages "$@"
