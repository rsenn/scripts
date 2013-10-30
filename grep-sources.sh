#!/bin/bash
EXTS="c cpp cxx h hpp hxx"

exec grep -iE "\\.($(IFS="| $IFS"; set $EXTS; echo "$*"))[^/]*\$"  "$@"
