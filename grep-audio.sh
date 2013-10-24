#!/bin/bash
IFS="
 "
EXTS="mp3 mp2 m4a m4b wma rm ogg flac mpc wav aif aiff raw"

exec grep -iE "\\.($(IFS="| $IFS"; set $EXTS; echo "$*"))" "$@"
