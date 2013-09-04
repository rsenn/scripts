#!/bin/sh

set -- mp3 ogg flac mpc m4a m4b wma 

#set -- "$@" rm
#set -- "$@" wav voc aif aiff 

exec grep -iE "\\.($(IFS='|'; echo "$*"))\$"
